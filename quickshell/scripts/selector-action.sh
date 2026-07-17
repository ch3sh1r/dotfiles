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
                code=$(rbw code "$item_id" 2>/dev/null || true)
                if [ -n "$code" ]; then
                    printf '%s' "$code" | wl-copy
                else
                    rbw get --field "$target" --clipboard "$item_id"
                fi
                ;;
            *)
                rbw get --field "$target" --clipboard "$item_id"
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
