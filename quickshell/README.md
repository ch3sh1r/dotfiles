# Quickshell

This shell supplies the Hyprland bar, wallpaper, pickers, notifications, session
lock, OSD and dictation status. `shell.qml` is the composition root: shared
services and session controllers are instantiated once; `Variants` creates
wallpaper, notification and bar windows for each connected output.

## Where things belong

| Location | Responsibility |
| --- | --- |
| `services/` | Device state, polling, desktop integrations and background controllers. |
| `bar/` | Per-output layout and widgets consuming shared backends. |
| `overlays/` | Windows, picker coordination and the session lock controller. |
| `components/` | UI building blocks plus the small `JsonPoller` and `JsonStore` utilities. |
| `scripts/` | CLI adapters for network, rotation, Bluetooth battery, clipboard and rbw. |
| `Theme.qml` | Palette, typography, geometry and resource paths. |
| `*State.qml` | Shared popup, stay-awake and night-mode state. |

`BarServices` owns one backend set for every bar. Polling and low-battery warnings
therefore do not multiply when a monitor is connected. `MediaKeys` receives the
same audio backend and the OSD explicitly. `IdleService` receives the OSD;
`SunsetService` applies the state edited by the bar's night-mode control.

Keep state and process ownership near the behavior they implement. A bar widget
renders a backend and forwards user actions; it should not start another copy of
that backend. File comments explain ownership, and block comments explain timing,
lifetimes and recovery constraints.

## Pickers and locking

`Launcher` supplies desktop entries, ranking and usage counts to `PickerWindow`.
`Selector` supplies clipboard/rbw data and navigates from an rbw entry to its
available fields. `PickerWindow` owns filtering, keyboard navigation, selection,
focus and dismissal. `PickerResult` only renders a description and reports hover
and activation; `ClipboardPreview` owns image/text presentation and text decoding.

The selector permits one data process at a time, keeps the latest queued request
and discards superseded output. Clipboard images are generated asynchronously by
the helper, so the visible clipboard picker retries while previews are pending.
The detail pane similarly discards text decoded for an old selection.

`Lock` deliberately keeps PAM, secure-lock confirmation, recovery and DPMS in one
controller. `LockSurface` is instantiated for locked outputs and reports input
back to that controller, which synchronizes password text and cursor position.
`KeyboardLayoutService` queries the main keyboard (falling back to the first
layout) when requested and listens for Hyprland layout events. It exposes
`layout`, `shortLayout` and `refresh()` without owning any authentication state.

`lock.isLocked()` means the compositor has confirmed a secure lock. A requested
lock alone is insufficient: `bin/sleep-lock` waits for that confirmation before
releasing its sleep inhibitor. Preserve the lock's reload IDs and synchronous
disk-marker write when changing recovery behavior.

## External commands and state

Hyprland bindings register against `GlobalShortcut` names with app ID
`quickshell`; scripts can use the existing IPC interface:

| Target | Methods |
| --- | --- |
| `launcher` | `open()`, `close()`, `toggle()` |
| `selector` | `rbw(target)`, `clipboard()`, `close()` |
| `lock` | `lock()`, `isLocked()`, `status()` |
| `osd` | `show(icon, percent)`, `message(icon, text)`, `close()` |
| `idle` | `toggle()`, `stayAwake(enabled)`, `status()` |
| `sunset` | `day()`, `night()`, `toggle()` |
| `notifications` | `toggleDnd()`, `setDnd(enabled)`, `clearHistory()`, `status()` |

For example, `qs ipc call osd show brightness 40` presents the OSD, and
`qs ipc call lock status` reports lock diagnostics. `selector.rbw` accepts
`menu` (also the default for an empty target) or a field/action target.

State files are resolved by `Quickshell.statePath()`:

| File | Contents |
| --- | --- |
| `idle.json` | Stay-awake setting. |
| `notifications.json` | DND and up to ten history snapshots, without live server objects. |
| `launcher-usage.json` | Application launch counts. |
| `selector-rbw-usage.json` | Last-use timestamps keyed by vault entry ID. |
| `session-lock` | `locked` marker for recovery across process restarts. |

Night-mode state is recomputed rather than persisted. Manual day/night overrides
last until the next schedule boundary (08:00 or 20:00); intensity defaults to 0.5.
Generated shaders alternate between two paths under `Quickshell.cachePath()` so
Hyprland recompiles intensity changes. Clipboard image previews live under
`${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/thumbnails`.

The selector data helper accepts `rbw`, `rbw-actions <id>` or `clipboard` and emits
JSON with `items`, optional `error` and optional `pendingPreviews`. Each item has
an `id`, `title` and optional display metadata. The action helper accepts
`<mode> <target> <id>`; clipboard `preview` emits decoded content on stdout,
while copy/delete and rbw actions perform the requested operation.

## Run and verify

`make quickshell` links this directory into `~/.config/quickshell`; the Hyprland
autostart runs `qs`. To run this config by path, use `qs -p ./quickshell` from the
repository root. A running default instance observes edits through the symlink
and reloads, so a second full shell is usually unnecessary.

Use the Qt 6 tools explicitly on systems that also install Qt 5. From the
repository root:

```bash
find quickshell -name '*.qml' -exec /usr/lib/qt6/bin/qmllint {} +
find quickshell/scripts -name '*.sh' -exec bash -n {} \;
qs log --tail 80 --no-color
```

Standalone `qmllint` can warn about Quickshell runtime types and singletons
discovered without a `qmldir`; compare diagnostics with the baseline and confirm
that the running shell reports `Configuration Loaded` without QML errors.

For changes to interaction or ownership, also exercise these session checks:

- Open the launcher, search, navigate with arrows, activate and dismiss it.
- Open clipboard text/image previews, switch selection quickly, delete an entry
  and close while data is loading. Open rbw's entry menu and field selection.
- Check notification actions, expiry, history, DND and persistence across reloads.
- Check volume/brightness OSD, dictation, stay-awake and night-mode controls.
- Connect/disconnect an output and compare portrait/landscape bars, shared state,
  picker placement and notification windows.
- In a dedicated lock test, check layout changes, wrong/right passwords, reload
  and process-restart recovery, DPMS blanking/wake and secure-lock diagnostics.

Record interactive checks as unverified when they have not been exercised;
syntax checks and a successful reload do not establish those behaviors.
