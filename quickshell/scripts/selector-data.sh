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
        has_password=false
        has_username=false
        has_totp=false

        if password=$(rbw get "$item_id" 2>/dev/null) && [ -n "$password" ]; then
            has_password=true
        fi
        unset password

        if username=$(rbw get --field username "$item_id" 2>/dev/null) && [ -n "$username" ]; then
            has_username=true
        fi
        unset username

        if totp=$(rbw code "$item_id" 2>/dev/null) && [ -n "$totp" ]; then
            has_totp=true
        fi
        unset totp

        jq -n \
            --argjson has_password "$has_password" \
            --argjson has_username "$has_username" \
            --argjson has_totp "$has_totp" '
            [
                if $has_password then { id: "password", title: "Copy password" } else empty end,
                if $has_username then { id: "username", title: "Copy username" } else empty end,
                if $has_totp then { id: "totp", title: "Copy TOTP" } else empty end
            ] | { items: . }
        '
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
