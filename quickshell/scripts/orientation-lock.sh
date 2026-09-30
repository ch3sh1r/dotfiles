#!/usr/bin/env bash
set -euo pipefail

action="${1:-status}"
monitor="${2:-DSI-1}"
rotator="${IIO_HYPRLAND_CMD:-$HOME/.local/bin/iio-hyprland-lua}"

# pgrep/pkill take a regex; escape the path so it matches literally.
rotator_pattern=$(printf '%s' "$rotator" | sed 's/[][\\.^$*+?(){}|]/\\&/g')
monitor_pattern=$(printf '%s' "$monitor" | sed 's/[][\\.^$*+?(){}|]/\\&/g')
pattern="$rotator_pattern( $monitor_pattern)?$"

is_running() {
    pgrep -f -- "$pattern" >/dev/null
}

status() {
    local locked transform

    if is_running; then
        locked=false
    else
        locked=true
    fi

    transform=$(hyprctl monitors -j all 2>/dev/null | jq -r --arg monitor "$monitor" '.[] | select(.name == $monitor) | .transform // empty' 2>/dev/null || true)

    jq -nc --argjson locked "$locked" --arg monitor "$monitor" --arg transform "$transform" \
        '{locked: $locked, monitor: $monitor, transform: $transform}'
}

case "$action" in
    status)
        status
        ;;
    toggle)
        if is_running; then
            pkill -f -- "$pattern"
        else
            nohup "$rotator" "$monitor" >/dev/null 2>&1 &
            sleep "${IIO_HYPRLAND_UNLOCK_STATUS_DELAY:-1}"
        fi
        status
        ;;
    *)
        printf 'usage: %s [status|toggle] [monitor]\n' "$0" >&2
        exit 2
        ;;
esac
