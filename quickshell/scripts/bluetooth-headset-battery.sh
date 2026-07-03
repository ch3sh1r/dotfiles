#!/usr/bin/env bash
set -euo pipefail

identifier="${1:-}"
mac=""

if [[ "$identifier" =~ ([[:xdigit:]]{2}([:_-][[:xdigit:]]{2}){5}) ]]; then
    mac="${BASH_REMATCH[1]//_/:}"
    mac="${mac//-/:}"
    mac="${mac^^}"
fi

if [[ -z "$mac" ]]; then
    printf '{"battery":null}\n'
    exit 0
fi

info="$(bluetoothctl info "$mac" 2>/dev/null || true)"
battery=""

while IFS= read -r line; do
    if [[ "$line" =~ Battery[[:space:]]Percentage:.*\(([0-9]+)\) ]]; then
        battery="${BASH_REMATCH[1]}"
        break
    fi

    if [[ "$line" =~ Battery[[:space:]]Percentage:[[:space:]]*([0-9]+) ]]; then
        battery="${BASH_REMATCH[1]}"
        break
    fi
done <<<"$info"

if [[ -n "$battery" ]]; then
    printf '{"battery":%s}\n' "$battery"
else
    printf '{"battery":null}\n'
fi
