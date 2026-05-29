#!/usr/bin/env bash
# Emit the current primary connection as a single JSON line for Quickshell.
# Output shapes:
#   {"type":"wifi","signal":72,"ssid":"name","ip":"1.2.3.4"}
#   {"type":"ethernet","name":"Wired","ip":"1.2.3.4"}
#   {"type":"disconnected"}

esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

# First non-loopback connected device wins (nmcli lists by priority).
line=$(nmcli -t -f TYPE,STATE,DEVICE,CONNECTION device status 2>/dev/null \
    | awk -F: '$2=="connected" && $1!="loopback" {print; exit}')

type=$(printf '%s' "$line" | cut -d: -f1)
dev=$(printf '%s'  "$line" | cut -d: -f3)
conn=$(printf '%s' "$line" | cut -d: -f4-)

ip=$(nmcli -t -f IP4.ADDRESS device show "$dev" 2>/dev/null \
    | head -n1 | cut -d: -f2 | cut -d/ -f1)

case "$type" in
wifi)
    info=$(nmcli -t -f IN-USE,SIGNAL,SSID device wifi 2>/dev/null \
        | awk -F: '$1=="*"{print; exit}')
    sig=$(printf '%s' "$info" | cut -d: -f2)
    ssid=$(printf '%s' "$info" | cut -d: -f3-)
    printf '{"type":"wifi","signal":%s,"ssid":"%s","ip":"%s"}\n' \
        "${sig:-0}" "$(esc "$ssid")" "$(esc "$ip")"
    ;;
ethernet | bridge | tun | vpn)
    printf '{"type":"ethernet","name":"%s","ip":"%s"}\n' \
        "$(esc "$conn")" "$(esc "$ip")"
    ;;
*)
    printf '{"type":"disconnected"}\n'
    ;;
esac
