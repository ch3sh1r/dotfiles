import Quickshell

// Entry point. One bar per connected monitor; Variants creates/destroys
// instances as screens come and go (the GPD's rotated DSI-1 + externals).
ShellRoot {
    Wallpaper {}
    Sunset {}
    Lock {}
    Idle {}

    Launcher {}
    Selector {}
    Notifications {}

    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
