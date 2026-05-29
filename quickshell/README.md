# Quickshell bar

A [Quickshell](https://quickshell.org/) reimplementation of the waybar config in
`../waybar`, keeping the same modules but using Quickshell's native services
instead of polling shell scripts.

## Layout

| Position | Module | Notes |
|----------|--------|-------|
| left | `Workspaces` | Hyprland workspaces over live IPC (no polling). Click activates, scroll cycles, urgent highlighted. |
| center | `Clock` | `SystemClock`. Hover for an **interactive calendar** (scroll = change month, right-click = today, click pins it). |
| right | `Volume` | Native **PipeWire** — scroll to change, click to mute, right-click `pavucontrol`, popup has a live slider. |
| right | `Network` | NM has no native QS service, so `scripts/network.sh` emits JSON parsed in QML. Wifi signal ramp / ethernet glyph. |
| right | `Mullvad` | Parses `mullvad status --json` natively. Click toggles; **right-click opens an in-shell location picker** (replaces the rofi menu). |
| right | `Tailscale` | Parses `tailscale status --json`. Popup lists peers colour-coded by online state. Click toggles up/down. |
| right | `Battery` | Native **UPower** (event-driven). Charge/discharge ramp, warning/critical colours, click toggles remaining time. Hidden when no battery. |

## What changed vs waybar ("new powers")

- **PipeWire** and **UPower** are bound directly — no `wpctl`/`acpi` polling.
- Workspaces update from Hyprland's event socket instead of a refresh interval.
- Tooltips are real QML: an interactive calendar, a volume slider, a clickable
  Mullvad location picker, and a colour-coded Tailscale peer list.
- One bar per monitor via `Variants` over `Quickshell.screens` (handles the
  GPD's rotated `DSI-1` plus any externals automatically).

All colours and metrics live in `Theme.qml` (the base16 palette from
`waybar/style.css` plus the Dracula accents the old calendar used).

## Install & run

```sh
make quickshell          # symlinks this dir to ~/.config/quickshell
qs                       # run in the foreground to see logs
```

To use it instead of waybar, edit `hypr/autostart.conf`:

```diff
-exec-once = waybar
+exec-once = qs
```

## Dependencies

- `quickshell` (with Qt6 / QtQuick)
- A Nerd Font for the glyphs (`Theme.iconFont`, defaults to `Symbols Nerd Font`)
- `pavucontrol`, `nm-connection-editor`, `mullvad`, `tailscale`, `nmcli` — same
  CLIs the waybar setup used
