#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
item_id="${2:-}"

case "$mode" in
    rbw)
        if ! out=$(rbw list --fields id,name,user,folder,type 2>&1); then
            jq -n --arg error "$out" '{ error: $error, items: [] }'
            exit 0
        fi

        jq -R -s '
            split("\n")
            | map(select(length > 0) | split("\t"))
            | map({
                id: .[0],
                title: (.[1] // .[0]),
                subtitle: ([.[2], .[3]] | map(select(. != null and . != "")) | join("  ·  "))
            })
            | { items: . }
        ' <<<"$out"
        ;;
    rbw-actions)
        if ! fields=$(rbw get --list-fields "$item_id" 2>&1); then
            jq -n --arg error "$fields" '{ error: $error, items: [] }'
            exit 0
        fi

        items_tmp=$(mktemp)
        trap 'rm -f "$items_tmp"' EXIT

        emit_field() {
            local field="$1"
            local value subtitle

            [ -n "$field" ] || return

            if [ "$field" = "password" ]; then
                value=$(rbw get "$item_id" 2>/dev/null || true)
            else
                value=$(rbw get --field "$field" "$item_id" 2>/dev/null || true)
            fi

            [ -n "$value" ] || return
            subtitle="$value"
            if [ "$field" = "password" ]; then
                subtitle=$(printf '%*s' "${#value}" '' | tr ' ' '.')
            elif [[ "$subtitle" == *$'\n'* ]]; then
                subtitle="${subtitle%%$'\n'*} ⏎..."
            fi

            jq -n --arg id "$field" --arg subtitle "$subtitle" '
                def field_label:
                    gsub("[_-]"; " ")
                    | split(" ")
                    | map(select(length > 0))
                    | join(" ");

                { id: $id, title: ("Copy " + ($id | field_label)), subtitle: $subtitle }
            ' >>"$items_tmp"
        }

        emit_totp() {
            local field value

            if value=$(rbw code "$item_id" 2>/dev/null) && [ -n "$value" ]; then
                jq -n --arg subtitle "$value" '{ id: "totp", title: "Copy TOTP", subtitle: $subtitle }' >>"$items_tmp"
                return
            fi

            while IFS= read -r field; do
                if [ "${field,,}" != "totp" ]; then
                    continue
                fi

                value=$(rbw get --field "$field" "$item_id" 2>/dev/null || true)
                [ -n "$value" ] || return
                jq -n --arg id "$field" --arg subtitle "$value" '{ id: $id, title: "Copy TOTP", subtitle: $subtitle }' >>"$items_tmp"
                return
            done <<<"$unique_fields"
        }

        unique_fields=$(printf '%s\n' "$fields" | sort -u)

        if printf '%s\n' "$unique_fields" | grep -Fxq username; then
            emit_field username
        fi

        if printf '%s\n' "$unique_fields" | grep -Fxq password; then
            emit_field password
        fi

        emit_totp

        while IFS= read -r field; do
            case "${field,,}" in
                username|password|totp)
                    continue
                    ;;
            esac

            emit_field "$field"
        done <<<"$unique_fields"

        jq -s '{ items: . }' "$items_tmp"
        ;;
    clipboard)
        tmp=$(mktemp)
        json_tmp=$(mktemp)
        thumbnail_dir="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/thumbnails"
        trap 'rm -f "$tmp" "$json_tmp"' EXIT

        if ! error=$(cliphist list >"$tmp" 2>&1); then
            jq -n --arg error "$error" '{ error: $error, items: [] }'
            exit 0
        fi

        mkdir -p "$thumbnail_dir"
        pending=false

        while IFS=$'\t' read -r id text; do
            if [[ "${text:-}" =~ ^\[\[\ binary\ data.*(jpg|jpeg|png|bmp) ]]; then
                ext="${BASH_REMATCH[1]}"
                image="$thumbnail_dir/$id.$ext"
                if [ ! -f "$image" ]; then
                    pending=true
                    (
                        tmp_image="$image.tmp"
                        printf '%s\t\n' "$id" | cliphist decode >"$tmp_image" 2>/dev/null && mv "$tmp_image" "$image"
                    ) &
                fi
            fi
        done <"$tmp"

        jq -R -s --arg thumbnail_dir "$thumbnail_dir" --argjson pending "$pending" '
            split("\n")
            | map(select(length > 0) | capture("^(?<id>[0-9]+)\\t(?<text>.*)$")?)
            | map(select(. != null) | . + {
                ext: ((.text | capture("^\\[\\[ binary data.*(?<ext>jpg|jpeg|png|bmp)")? // {}).ext // "")
            })
            | map({
                id: .id,
                title: .text,
                subtitle: ("#" + .id),
                icon: (if .ext != "" then "image-x-generic" else "edit-paste" end),
                image: (if .ext != "" then ($thumbnail_dir + "/" + .id + "." + .ext) else "" end)
            })
            | { pendingPreviews: $pending, items: . }
        ' <"$tmp"
        ;;
    *)
        jq -n --arg error "unknown selector mode: $mode" '{ error: $error, items: [] }'
        ;;
esac
