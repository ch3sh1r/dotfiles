# @ch3sh1r's dotfiles

## Installation

Symlinks configs into `~/.config`, `~/.local/bin` and `~`. Existing real
(non-symlink) files are left untouched — `make` will refuse and ask you to
move them away first.

```bash
git clone --recursive https://github.com/ch3sh1r/dotfiles ~/.local/dotfiles
cd ~/.local/dotfiles
make
```


Fish plugins (fisher, z) are not committed. Install them from
`fish/fish_plugins` with:

```bash
make fish-plugins
```

## Quickshell

See [the Quickshell guide](quickshell/README.md) for component ownership,
IPC commands, persisted state and checks when changing the shell.

## Mouse cursor

Restore and select the bundled [NeuroDance-Dracula](icons/NeuroDance-Dracula/README.md) theme:

```bash
make cursor
```

`make` includes `make cursor`: it copies the ready-to-use theme from
`icons/NeuroDance-Dracula` to `~/.local/share/icons/NeuroDance-Dracula`, then
sets size 24 in GTK 3/4 and GSettings, and fixes the user `default` theme's
inheritance. Other GTK settings are preserved; changed INI files get numbered
`.before-cursor` backups. Python 3 is required; restoration works offline without
the original theme or Git commands. Identical existing installations are reused;
different existing themes at the destination are left untouched.

Original cursor theme: [v1ewport (viewport), NEURODANCE-CURSOR](https://github.com/v1ewport/NEURODANCE-CURSOR).
Original concept art: [Anna Kuźmińska](https://www.behance.net/gallery/127222375/Cyberpunk-2077-UI-Art-and-UI-Art-Concepts),
as credited by upstream. This local variant changes the colors to the Dracula
palette; the original cursor designs are by their respective authors.

The Dracula variant replaces the main red accent with purple (`#bd93f9`), maps
neutral details to the background/foreground palette, and uses Dracula accents
for other semantic hues. The native XCursor transform preserves alpha, all frame
headers, sizes, hotspots, and animation delays. The original theme is retained.

Log out and back in after installation so UWSM services and existing apps receive
`XCURSOR_THEME=NeuroDance-Dracula`. Hyprland uses the same XCursor assets as clients.
The compositor keeps hardware cursors with `cursor.use_cpu_buffer = 1` as a
workaround to test on Intel + AMD displays. This is not yet a visually confirmed
fix: verify repeated crossings between displays at scales 1 and 1.5, including
pointer/text shape changes, and check for black squares or flashing duplicates.
If the square persists, temporarily test `cursor.no_hardware_cursors = 1` and
check for the previously observed software-cursor duplicate before saving it.

Links should use the shape requested by the application: a theme changes the
images, not browser CSS or terminal link-detection rules. Check a reproducible
case in the affected app if a text cursor still appears over a clickable link.

## Hyprland session (UWSM)

greetd starts Hyprland through UWSM. Apply the setup from this directory:

```bash
sudo pacman -S --needed uwsm
make uwsm
systemctl --user daemon-reload
systemctl --user enable voxtype.service
sudo cp --backup=numbered -p /etc/greetd/config.toml /etc/greetd/config.toml.before-uwsm
sudoedit /etc/greetd/config.toml
```

Use the following system config in `/etc/greetd/config.toml`:

```toml
[terminal]
vt = 1

[initial_session]
command = "/usr/bin/uwsm start -- hyprland.desktop"
user = "ch3sh1r"

[default_session]
command = "agreety --cmd '/usr/bin/uwsm start -- hyprland.desktop'"
user = "greeter"
```

This preserves autologin for `ch3sh1r`; change the username for another account.
Save your work and reboot after the initial setup to use UWSM.
Autostart programs, application shortcuts and the Quickshell launcher use
`uwsm app`.

After login, check:

```bash
systemctl --user status graphical-session.target wayland-wm@hyprland.desktop.service voxtype.service
```

To restore direct startup,
copy `/etc/greetd/config.toml.before-uwsm` back to `/etc/greetd/config.toml`
with sudo, then reboot.

## Laptop lid and external displays

Hyprland handles display changes through `modules/lid.lua`, using lid bindings
and one-shot timers after monitor events. There is no additional daemon or
periodic lid poll. The lid sensor on this machine is
`/proc/acpi/button/lid/LID0/state`; adjust that path for different hardware.

| Action | Result |
| --- | --- |
| Close with an active external display | Disable the panel's touchscreen/stylus and remove `DSI-1` from the layout; Hyprland relocates its workspaces. Show the panel's active desktop if it contains windows. Continue without locking. |
| Close without an active external display | Lock through the existing `sleep-lock` inhibitor and suspend, on battery or AC. |
| Disable/unplug the last external display while closed | Restore the panel for locking, then suspend after the monitor layout settles for two seconds. |
| Open | Restore the panel's saved mode, position and scale, using the latest rotation, and enable its touchscreen/stylus. Workspaces remain on the external display. |

The rotator caches orientation through the lid module while the panel is closed
or disabled, and cannot enable it. Stopping the rotator still locks rotation.
`egpu disable` enables the panel and moves all workspaces before disabling
externals in one compositor callback. With the lid closed this leads to sleep;
open the lid first to keep working on the panel. Stay-awake only controls idle
blanking/locking and does not override lid actions.

Configure logind manually so closing the lid without external displays suspends
on both battery and AC. Create `/etc/systemd/logind.conf.d/60-lid.conf`:

```bash
sudo mkdir -p /etc/systemd/logind.conf.d
sudoedit /etc/systemd/logind.conf.d/60-lid.conf
```

Use these settings:

```ini
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
```

Reboot when convenient to activate the settings. Docked operation remains awake.
Hyprland additionally handles software-disabled external outputs, which logind
may still regard as connected. The Makefile does not configure logind.

For diagnosis, use `cat /proc/acpi/button/lid/LID0/state`,
`hyprctl monitors all -j`, `hyprctl configerrors`,
`systemd-analyze cat-config systemd/logind.conf`, and
`systemd-inhibit --list`. Before a sleep test, confirm the `quickshell` sleep
delay inhibitor from `sleep-lock` is present. Hardware suspend/resume, hotplug
and lock-screen authentication require an interactive check on the device.

Use `bash -n bin/egpu bin/iio-hyprland-lua` and
`Hyprland --verify-config -c "$PWD/hypr/hyprland.lua"` for syntax/config checks.

## Dictation for Codex

Voxtype transcribes locally and copies the result to the Wayland clipboard.
Install `voxtype-bin` (listed in `gpd-p3.list`) and download the multilingual
Whisper model with `voxtype setup --download --model small`. Download
`large-v3-turbo` the same way for higher-accuracy dictation. UWSM activates
`graphical-session.target`, which starts the enabled packaged user service:

```bash
systemctl --user enable --now voxtype.service
```

Russian is fixed as the recognition language. Press `Super+D` to toggle fast
dictation (`small`), or `Super+Shift+D`
to toggle higher-accuracy dictation (`large-v3-turbo`). Use the same shortcut
to stop the recording. Review the result, then paste it into Codex in Alacritty
with `Ctrl+Shift+V`. Quickshell keeps a red recording timer or an amber speech
recognition indicator on screen until that phase finishes.
`Super+V` opens the existing clipboard history if you need an earlier result.
