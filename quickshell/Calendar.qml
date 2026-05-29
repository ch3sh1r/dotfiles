import QtQuick

// A Monday-first month grid. Scroll to change month, right-click to jump back
// to the current month. `today` is the live date from the clock.
Item {
    id: root

    property date today: new Date()
    // The month currently shown (1..12) and its year.
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth() // 0..11

    function reset() {
        viewYear = today.getFullYear();
        viewMonth = today.getMonth();
    }

    function shiftMonth(delta) {
        let m = viewMonth + delta;
        let y = viewYear;
        while (m < 0) {
            m += 12;
            y -= 1;
        }
        while (m > 11) {
            m -= 12;
            y += 1;
        }
        viewMonth = m;
        viewYear = y;
    }

    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var dayNames: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    // Days laid out as a flat 42-cell (6x7) grid, Monday first.
    readonly property var cells: {
        let first = new Date(viewYear, viewMonth, 1);
        // JS: 0=Sun..6=Sat -> shift so Monday=0.
        let lead = (first.getDay() + 6) % 7;
        let start = new Date(viewYear, viewMonth, 1 - lead);
        let out = [];
        for (let i = 0; i < 42; i++) {
            let d = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i);
            out.push(d);
        }
        return out;
    }

    function isToday(d) {
        return d.getFullYear() === today.getFullYear() && d.getMonth() === today.getMonth() && d.getDate() === today.getDate();
    }

    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight

    WheelHandler {
        onWheel: function (event) {
            root.shiftMonth(event.angleDelta.y > 0 ? -1 : 1);
        }
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: root.reset()
    }

    Column {
        id: col
        spacing: 6

        // Header: month + year, centred.
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.monthNames[root.viewMonth] + " " + root.viewYear
            color: Theme.purple
            font.bold: true
            font.pixelSize: Theme.fontSize + 1
        }

        Grid {
            columns: 7
            rowSpacing: 2
            columnSpacing: 2

            // Weekday header row.
            Repeater {
                model: root.dayNames
                delegate: Item {
                    required property var modelData
                    implicitWidth: 24
                    implicitHeight: 18
                    Label {
                        anchors.centerIn: parent
                        text: parent.modelData
                        color: Theme.yellow
                        font.bold: true
                    }
                }
            }

            // 42 day cells.
            Repeater {
                model: root.cells
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool inMonth: modelData.getMonth() === root.viewMonth
                    readonly property bool today: root.isToday(modelData)

                    implicitWidth: 24
                    implicitHeight: 18
                    radius: Theme.radius
                    color: today ? Theme.pink : "transparent"

                    Label {
                        anchors.centerIn: parent
                        text: parent.modelData.getDate()
                        color: parent.today ? Theme.base00 : (parent.inMonth ? Theme.fgBright : Theme.base03)
                        font.bold: parent.today
                    }
                }
            }
        }
    }
}
