#!/usr/bin/env bash
set -euo pipefail

action="${1:-status}"
monitor="${2:-DSI-1}"

is_running() {
    pgrep -x iio-hyprland >/dev/null
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
            pkill -x iio-hyprland
        else
            nohup iio-hyprland "$monitor" >/dev/null 2>&1 &
        fi
        status
        ;;
    *)
        printf 'usage: %s [status|toggle] [monitor]\n' "$0" >&2
        exit 2
        ;;
esac
