import Quickshell
import "bar"
import "overlays"
import "services"

// Entry point. One bar per connected monitor; Variants creates/destroys
// instances as screens come and go (the GPD's rotated DSI-1 + externals).
ShellRoot {
    BarServices { id: barServices }

    Variants {
        model: Quickshell.screens

        Wallpaper {
            required property var modelData
            screen: modelData
        }
    }

    Sunset {}
    Lock {}
    Idle {}

    Launcher {}
    Selector {}
    Notifications { backend: barServices.notifications }

    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
            services: barServices
        }
    }
}
