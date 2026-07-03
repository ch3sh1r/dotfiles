#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
target="${2:-}"
item_id="${3:-}"

case "$mode" in
    rbw)
        case "$target" in
            password)
                rbw get --clipboard "$item_id"
                ;;
            username)
                rbw get --field username --clipboard "$item_id"
                ;;
            totp)
                rbw code "$item_id" | wl-copy
                ;;
            *)
                printf 'unknown rbw target: %s\n' "$target" >&2
                exit 2
                ;;
        esac
        ;;
    clipboard)
        case "$target" in
            copy)
                printf '%s\t\n' "$item_id" | cliphist decode | wl-copy
                ;;
            delete)
                printf '%s\n' "$item_id" | cliphist delete
                ;;
            wipe)
                cliphist wipe
                ;;
            *)
                printf 'unknown clipboard action: %s\n' "$target" >&2
                exit 2
                ;;
        esac
        ;;
    *)
        printf 'unknown selector mode: %s\n' "$mode" >&2
        exit 2
        ;;
esac
