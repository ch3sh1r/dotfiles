#!/usr/bin/env python3
"""Restore and select the bundled NeuroDance-Dracula cursor theme."""

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


THEME = "NeuroDance-Dracula"
BUNDLED_THEME = Path(__file__).resolve().parent.parent / "icons" / THEME


def install_theme(data):
    source = BUNDLED_THEME
    for name in ("index.theme", "palette-version", "cursors/left_ptr", "cursors/pointer", "cursors/text"):
        if not (source / name).is_file():
            raise SystemExit(f"Missing bundled theme file: {source / name}")
    icons = data / "icons"
    destination = icons / THEME
    if destination.exists():
        # Older local installations lack the bundled README; compare assets.
        files = [p.relative_to(source) for p in source.rglob("*") if p.is_file() and p.name != "README.md"]
        same = all((destination / name).is_file() and (destination / name).read_bytes() == (source / name).read_bytes() for name in files)
        expected = {p.name for p in (source / "cursors").iterdir()}
        actual = {p.name for p in (destination / "cursors").iterdir()} if (destination / "cursors").is_dir() else set()
        if same and expected == actual:
            return
        raise SystemExit(f"Different theme at {destination}; move it aside before restoring")
    if destination.is_symlink():
        raise SystemExit(f"Broken symlink at {destination}; move it aside before restoring")
    icons.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=".neurodance-dracula-", dir=icons) as temporary:
        stage = Path(temporary) / THEME
        shutil.copytree(source, stage)
        stage.rename(destination)
    print(f"Installed: {destination}")


def update_ini(path, section, values):
    # Follow existing settings symlinks; preserve unrelated settings and comments.
    path = path.resolve()
    old = path.read_text() if path.exists() else ""
    lines = old.splitlines(keepends=True)
    output = []
    inside = False
    found = False
    pending = dict(values)
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            if inside:
                output.extend(f"{key}={value}\n" for key, value in pending.items())
                pending.clear()
            inside = stripped == f"[{section}]"
            found |= inside
        if inside and "=" in stripped and not stripped.startswith(("#", ";")):
            key = stripped.split("=", 1)[0].strip()
            if key in values:
                if key in pending:
                    output.append(f"{key}={pending.pop(key)}\n")
                continue
        output.append(line if line.endswith("\n") else line + "\n")
    if not found:
        output.append(f"[{section}]\n")
    output.extend(f"{key}={value}\n" for key, value in pending.items())
    new = "".join(output)
    if new == old:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        backup = path.with_name(path.name + ".before-cursor")
        number = 1
        while backup.exists():
            backup = path.with_name(path.name + f".before-cursor.{number}")
            number += 1
        shutil.copy2(path, backup)
        print(f"Backup: {backup}")
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as tmp:
        tmp.write(new)
        temporary = Path(tmp.name)
    try:
        temporary.chmod(path.stat().st_mode & 0o777 if path.exists() else 0o644)
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)
    print(f"Updated: {path}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--home", type=Path, default=Path.home(), help="Installation home")
    parser.add_argument("--skip-gsettings", action="store_true", help="For offline/staged installs")
    args = parser.parse_args()
    home = args.home.resolve()
    # A staged home must never modify the real desktop's GSettings.
    staged = home != Path.home().resolve()
    config = home / ".config" if staged else Path(os.environ.get("XDG_CONFIG_HOME", home / ".config"))
    data = home / ".local/share" if staged else Path(os.environ.get("XDG_DATA_HOME", home / ".local/share"))
    install_theme(data)
    for version in ("gtk-3.0", "gtk-4.0"):
        update_ini(config / version / "settings.ini", "Settings", {
            "gtk-cursor-theme-name": THEME,
            "gtk-cursor-theme-size": "24",
        })
    update_ini(data / "icons/default/index.theme", "Icon Theme", {"Inherits": THEME})
    if not args.skip_gsettings and not staged:
        if shutil.which("gsettings") and os.environ.get("DBUS_SESSION_BUS_ADDRESS"):
            for key, value in (("cursor-theme", THEME), ("cursor-size", "24")):
                subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", key, value], check=True)
        else:
            print("No desktop GSettings session; Hyprland will synchronize it on theme load.")
    print(f"Selected {THEME}, size 24")


if __name__ == "__main__":
    main()
