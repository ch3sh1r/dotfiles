#!/usr/bin/env bash
set -euo pipefail

action="${1:-status}"
monitor="${2:-DSI-1}"
rotator="${IIO_HYPRLAND_CMD:-$HOME/.config/hypr/scripts/iio-hyprland-lua}"

is_running() {
    pgrep -f "$rotator $monitor" >/dev/null
}

status() {
    local locked transform

    if is_running; then
        locked=false
    else
        locked=true
    fi

    transform=$(hyprctl monitors -j all 2>/dev/null | jq -r --arg monitor "$monitor" '.[] | select(.name == $monitor) | .transform // empty' 2>/dev/null || true)

    printf '{"locked":%s,"monitor":"%s","transform":"%s"}\n' "$locked" "$monitor" "$transform"
}

case "$action" in
    status)
        status
        ;;
    toggle)
        if is_running; then
            pkill -f "$rotator $monitor"
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
