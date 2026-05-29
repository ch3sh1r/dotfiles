#!/usr/bin/env bash
# Daemon-agnostic network status for Quickshell (no NetworkManager needed).
# Reads the kernel directly: sysfs for interfaces, /proc/net/wireless for wifi
# link quality, `iw` for SSID, `ip` for the address. Emits one JSON line:
#   {"type":"wifi","signal":72,"ssid":"name","ip":"1.2.3.4"}
#   {"type":"ethernet","name":"enp0s1","ip":"1.2.3.4"}
#   {"type":"disconnected"}

esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

ip_of() {
    ip -4 -o addr show "$1" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1
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
if [ -n "$wifi" ] && [ "$(cat "/sys/class/net/$wifi/operstate" 2>/dev/null)" = up ]; then
    link=$(awk -v ifc="$wifi:" '$1==ifc {q=$3; sub(/\./,"",q); print q}' /proc/net/wireless 2>/dev/null)
    sig=0
    [ -n "$link" ] && sig=$((link * 100 / 70))
    [ "$sig" -gt 100 ] && sig=100
    ssid=$(iw dev "$wifi" link 2>/dev/null | sed -n 's/^[[:space:]]*SSID: //p' | head -n1)
    printf '{"type":"wifi","signal":%s,"ssid":"%s","ip":"%s"}\n' \
        "$sig" "$(esc "$ssid")" "$(esc "$(ip_of "$wifi")")"
    exit 0
fi

# Otherwise the first wired interface that's up.
for d in /sys/class/net/*; do
    i=${d##*/}
    [ "$i" = lo ] && continue
    [ -d "$d/wireless" ] && continue
    [ -e "$d/phy80211" ] && continue
    if [ "$(cat "$d/operstate" 2>/dev/null)" = up ]; then
        printf '{"type":"ethernet","name":"%s","ip":"%s"}\n' \
            "$(esc "$i")" "$(esc "$(ip_of "$i")")"
        exit 0
    fi
done

printf '{"type":"disconnected"}\n'
