import Quickshell

Scope {
    readonly property date date: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
