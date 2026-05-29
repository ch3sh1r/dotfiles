pragma Singleton

import QtQuick
import Quickshell

// Central palette + metrics, ported from waybar/style.css (base16) with the
// Dracula accents that the old clock calendar used. Tweak everything here.
Singleton {
    id: root

    // base16 palette (matches waybar/style.css)
    readonly property color base00: "#181818"
    readonly property color base01: "#282a36"
    readonly property color base02: "#3b3e47"
    readonly property color base03: "#585858"
    readonly property color base04: "#b8b8b8"
    readonly property color base05: "#d8d8d8"
    readonly property color base06: "#e8e8e8"
    readonly property color base07: "#f8f8f8"
    readonly property color base08: "#ab4642" // red
    readonly property color base09: "#dc9656" // orange
    readonly property color base0A: "#f7ca88" // yellow
    readonly property color base0B: "#a1b56c" // green
    readonly property color base0C: "#86c1b9" // cyan
    readonly property color base0D: "#7cafc2" // blue
    readonly property color base0E: "#ba8baf" // magenta
    readonly property color base0F: "#a16946" // brown

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

    // typography — Hack Nerd Font, matching alacritty/fuzzel/hyprlock. It
    // carries both the text and the Nerd-Font glyphs, so one font does both.
    readonly property string font: "Hack Nerd Font"
    readonly property string iconFont: "Hack Nerd Font"
    readonly property int fontSize: 12
    readonly property int iconSize: 14

    // metrics
    readonly property int barHeight: 28
    readonly property int pillHeight: 20
    readonly property int pillMinWidth: 20
    readonly property int radius: 4
    readonly property int gap: 4
    readonly property int hPad: 6
}
