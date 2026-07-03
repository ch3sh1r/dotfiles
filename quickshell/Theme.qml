pragma Singleton

import QtQuick
import Quickshell

// Central palette + metrics, ported from waybar/style.css (base16) with the
// Dracula accents that the old clock calendar used. Tweak everything here.
Singleton {
    id: root

    // Dracula palette.
    readonly property color base00: "#282a36" // background
    readonly property color base01: "#282a36" // bar / main surface
    readonly property color base02: "#44475a" // selection / raised surface
    readonly property color base03: "#6272a4" // comments / muted text
    readonly property color base04: "#c0c3d4"
    readonly property color base05: "#f8f8f2" // foreground
    readonly property color base06: "#ffffff"
    readonly property color base07: "#ffffff"
    readonly property color base08: "#ff5555" // red
    readonly property color base09: "#ffb86c" // orange
    readonly property color base0A: "#f1fa8c" // yellow
    readonly property color base0B: "#50fa7b" // green
    readonly property color base0C: "#8be9fd" // cyan
    readonly property color base0D: "#8be9fd" // blue/cyan
    readonly property color base0E: "#bd93f9" // purple
    readonly property color base0F: "#ff79c6" // pink

    // Dracula accents (kept from the old calendar markup)
    readonly property color purple: "#bd93f9"
    readonly property color cyan: "#8be9fd"
    readonly property color pink: "#ff79c6"
    readonly property color yellow: "#f1fa8c"

    // semantic roles
    readonly property color bg: base01           // bar background
    readonly property color pillBg: base02        // module pill background
    readonly property color pillBgHover: Qt.lighter(base02, 1.25)
    readonly property color fg: base04            // default text
    readonly property color fgBright: base05
    readonly property color accent: purple        // active workspace outline
    readonly property color urgent: "#ee2e24"
    readonly property color warning: base0A
    readonly property color critical: base08
    readonly property color good: base05          // "active/connected" — gray, not green

    // typography — Hack Nerd Font, matching alacritty/hyprlock. It
    // carries both the text and the Nerd-Font glyphs, so one font does both.
    readonly property string font: "Hack Nerd Font"
    readonly property string iconFont: "Hack Nerd Font"
    readonly property int fontSize: 12
    readonly property int menuFontSize: 14
    readonly property int menuTitleFontSize: 16
    readonly property int menuInputFontSize: 18
    readonly property int iconSize: 12

    // metrics
    readonly property int barHeight: 22
    readonly property int pillHeight: 18
    readonly property int pillMinWidth: 20
    readonly property int radius: 4
    readonly property int gap: 4
    readonly property int hPad: 6
}
