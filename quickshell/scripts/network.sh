#!/usr/bin/env bash
# Daemon-agnostic network status for Quickshell (no NetworkManager needed).
# Reads the kernel directly: sysfs for interfaces, /proc/net/wireless for wifi
# link quality, `iw` for SSID, `ip` for the address. Emits one JSON line:
#   {"type":"wifi","signal":72,"ssid":"name","ip":"1.2.3.4"}
#   {"type":"ethernet","name":"enp0s1","ip":"1.2.3.4"}
#   {"type":"disconnected"}

set -euo pipefail

ip_of() {
    ip -4 -o addr show "$1" 2>/dev/null | awk '{ sub(/\/.*/, "", $4); print $4; exit }' || true
}

gateway_of() {
    ip -4 route show default dev "$1" 2>/dev/null | awk '/^default/ {print $3; exit}' || true
}

operstate_of() {
    cat "/sys/class/net/$1/operstate" 2>/dev/null || true
}

# Bridges, containers and VPN tunnels are not a physical wired link.
is_virtual() {
    case "$1" in
        lo | docker* | veth* | br-* | virbr* | tailscale* | wg* | tun* | tap*) return 0 ;;
    esac
    [ -e "/sys/devices/virtual/net/$1" ]
}

# Find the wireless interface (if any).
wifi=""
for d in /sys/class/net/*; do
    i=${d##*/}
    [ "$i" = lo ] && continue
    if [ -d "$d/wireless" ] || [ -e "$d/phy80211" ]; then
        wifi=$i
        break
    fi
done

# Connected wifi?
if [ -n "$wifi" ] && [ "$(operstate_of "$wifi")" = up ]; then
    link=$(awk -v ifc="$wifi:" '$1==ifc {q=$3; sub(/\./,"",q); print q}' /proc/net/wireless 2>/dev/null || true)
    sig=0
    [ -n "$link" ] && sig=$((link * 100 / 70))
    [ "$sig" -gt 100 ] && sig=100
    ssid=$(iw dev "$wifi" link 2>/dev/null | awk '/^[[:space:]]*SSID: / { sub(/^[[:space:]]*SSID: /, ""); print; exit }' || true)
    jq -nc --arg name "$wifi" --argjson signal "$sig" --arg ssid "$ssid" \
        --arg ip "$(ip_of "$wifi")" --arg gateway "$(gateway_of "$wifi")" \
        '{type: "wifi", name: $name, signal: $signal, ssid: $ssid, ip: $ip, gateway: $gateway}'
    exit 0
fi

# Otherwise the first wired interface that's up.
for d in /sys/class/net/*; do
    i=${d##*/}
    is_virtual "$i" && continue
    [ -d "$d/wireless" ] && continue
    [ -e "$d/phy80211" ] && continue
    if [ "$(operstate_of "$i")" = up ]; then
        jq -nc --arg name "$i" --arg ip "$(ip_of "$i")" --arg gateway "$(gateway_of "$i")" \
            '{type: "ethernet", name: $name, ip: $ip, gateway: $gateway}'
        exit 0
    fi
done

printf '{"type":"disconnected"}\n'
