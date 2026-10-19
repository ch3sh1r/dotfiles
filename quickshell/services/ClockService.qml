import Quickshell

// One minute-resolution clock keeps every bar and calendar on the same date.
Scope {
    readonly property date date: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
