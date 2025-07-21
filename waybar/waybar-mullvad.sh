#!/usr/bin/env bash

COLOR_CONNECTED="green"
COLOR_DISCONNECTED="red"
FAVORITES=("de berlin" "se" "us nyc" "fr" "nl" "gb" "jp")
COUNTRIES=("al" "au" "at" "be" "br" "bg" "ca" "cz" "dk" "fi" "fr" "de" "gr" "hk" "hu" "ie" "il" "it" "jp" "lv" "lu" "md" "nl" "nz" "no" "pl" "ro" "rs" "sg" "es" "se" "ch" "gb" "ae" "us")

get_status_json() {
    mullvad status --json
}

is_connected() {
    status=$(get_status_json | jq -r '.state')
    [[ "$status" == "connected" ]]
}

toggle_vpn() {
    if is_connected; then
        mullvad disconnect
    else
        mullvad connect
    fi
}

show_status() {
    if is_connected; then
        city=$(get_status_json | jq -r '.details.location.city')
        country=$(get_status_json | jq -r '.details.location.country')
        ip=$(get_status_json | jq -r '.details.location.ipv4')
        tooltip="$city, $country ($ip)"
        echo "{\"text\":\"$city\",\"class\":\"connected\",\"alt\":\"connected\",\"tooltip\":\"$tooltip\"}"
    else
        echo "{\"text\":\"Disconnected\",\"class\":\"disconnected\",\"alt\":\"disconnected\",\"tooltip\":\"Mullvad is not connected\"}"
    fi
}

show_menu() {
    if ! command -v rofi >/dev/null; then
        notify-send "Mullvad VPN" "rofi not installed!"
        exit 1
    fi

    options=("Toggle VPN Connection")
    for loc in "${FAVORITES[@]}"; do options+=("⭐ $loc"); done
    for code in "${COUNTRIES[@]}"; do options+=("🌍 $code"); done

    selection=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "Mullvad VPN" -theme-str 'listview { lines: 15; }')
    if [[ "$selection" == *"Toggle"* ]]; then
        toggle_vpn && exit 0
    fi

    location=$(echo "$selection" | sed -e 's/^⭐ //' -e 's/^🌍 //')
    if [[ -n "$location" ]]; then
        mullvad relay set location $location && sleep 1 && $VPN_CONNECT
    fi
}

case "$1" in
--status)
    show_status
    ;;
--toggle)
    toggle_vpn
    ;;
--menu)
    show_menu
    ;;
*)
    echo "Usage: $0 --status | --toggle | --menu"
    ;;
esac
