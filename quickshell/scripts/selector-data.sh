#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"

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
                subtitle: ([.[2], .[3]] | map(select(. != null and . != "")) | join("  ·  ")),
                icon: "dialog-password"
            })
            | { items: . }
        ' <<<"$out"
        ;;
    clipboard)
        tmp=$(mktemp)
        trap 'rm -f "$tmp"' EXIT

        if ! error=$(cliphist list >"$tmp" 2>&1); then
            jq -n --arg error "$error" '{ error: $error, items: [] }'
            exit 0
        fi

        jq -R -s '
            split("\n")
            | map(select(length > 0) | capture("^(?<id>[0-9]+)\\t(?<text>.*)$")?)
            | map(select(. != null) | {
                id: .id,
                title: .text,
                subtitle: ("#" + .id),
                icon: (if (.text | test("^\\[\\[ binary data")) then "image-x-generic" else "edit-paste" end)
            })
            | { items: . }
        ' <"$tmp"
        ;;
    *)
        jq -n --arg error "unknown selector mode: $mode" '{ error: $error, items: [] }'
        ;;
esac
