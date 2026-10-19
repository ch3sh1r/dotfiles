import Quickshell
import "bar"
import "overlays"
import "services"

// Composition root: shared backends and session controllers live once per shell.
// Variants owns screen-specific windows and follows monitor hotplug.
ShellRoot {
    // Share polling, device tracking and the notification server across all bars.
    BarServices { id: barServices }

    // Wallpaper surfaces must cover every connected output.
    Variants {
        model: Quickshell.screens

        Wallpaper {
            required property var modelData
            screen: modelData
        }
    }

    // Session-wide controllers; pass the OSD explicitly to its producers.
    SunsetService {}
    Lock {}
    Osd { id: osd }
    Dictation {}
    IdleService { osd: osd }
    MediaKeys {
        audio: barServices.audio
        osd: osd
    }

    // Pickers choose the focused output when opened.
    Launcher {}
    Selector {}

    // Each output renders the same shared notification model.
    Variants {
        model: Quickshell.screens

        Notifications {
            required property var modelData
            screen: modelData
            backend: barServices.notifications
        }
    }

    // Bar layout adapts to each output; its backends remain shared.
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
            services: barServices
        }
    }
}
