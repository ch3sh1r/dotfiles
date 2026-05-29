import QtQuick

// Full-year calendar, matching the old waybar clock calendar:
//   mode: year, 3 month-columns, ISO week numbers on the right.
// Scroll changes the year; right-click jumps back to the current year.
// Colours mirror waybar: purple months, yellow weekdays, cyan weeks,
// pink underlined today.
Item {
    id: root

    property date today: new Date()
    property int viewYear: today.getFullYear()

    function reset() {
        viewYear = today.getFullYear();
    }
    function shiftYear(delta) {
        viewYear += delta;
    }

    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var dayNames: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    readonly property int cell: 16
    readonly property int weekCell: 26

    function isToday(y, m, d) {
        return y === today.getFullYear() && m === today.getMonth() && d === today.getDate();
    }

    function isoWeek(d) {
        let date = new Date(d.getFullYear(), d.getMonth(), d.getDate());
        let day = (date.getDay() + 6) % 7;       // Mon=0
        date.setDate(date.getDate() - day + 3);   // Thursday of this week
        let firstThu = new Date(date.getFullYear(), 0, 4);
        let fday = (firstThu.getDay() + 6) % 7;
        firstThu.setDate(firstThu.getDate() - fday + 3);
        return 1 + Math.round((date.getTime() - firstThu.getTime()) / (7 * 86400000));
    }

    // Flat 56-cell model (7 header + 1 blank + 6*(7 days + 1 week)) for one month.
    function monthCells(year, month) {
        let out = [];
        for (let i = 0; i < 7; i++)
            out.push({
                type: "wd",
                text: dayNames[i]
            });
        out.push({
            type: "blank"
        });

        let first = new Date(year, month, 1);
        let lead = (first.getDay() + 6) % 7;
        let start = new Date(year, month, 1 - lead);

        for (let w = 0; w < 6; w++) {
            let rowHasMonth = false;
            let row = [];
            for (let d = 0; d < 7; d++) {
                let dt = new Date(start.getFullYear(), start.getMonth(), start.getDate() + w * 7 + d);
                let inM = dt.getMonth() === month;
                if (inM)
                    rowHasMonth = true;
                row.push({
                    type: "day",
                    day: dt.getDate(),
                    inMonth: inM,
                    today: isToday(dt.getFullYear(), dt.getMonth(), dt.getDate())
                });
            }
            for (const c of row)
                out.push(c);
            let mon = new Date(start.getFullYear(), start.getMonth(), start.getDate() + w * 7);
            out.push({
                type: "week",
                week: rowHasMonth ? isoWeek(mon) : 0
            });
        }
        return out;
    }

    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight

    WheelHandler {
        onWheel: function (event) {
            root.shiftYear(event.angleDelta.y > 0 ? -1 : 1);
        }
    }
    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: root.reset()
    }

    Column {
        id: col
        spacing: 8

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.viewYear
            color: Theme.purple
            font.bold: true
            font.pixelSize: Theme.fontSize + 3
        }

        Grid {
            columns: 3
            rowSpacing: 12
            columnSpacing: 16

            Repeater {
                model: 12

                delegate: Column {
                    id: month
                    required property int index
                    spacing: 3

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.monthNames[month.index]
                        color: Theme.purple
                        font.bold: true
                    }

                    Grid {
                        columns: 8
                        rowSpacing: 1
                        columnSpacing: 1

                        Repeater {
                            model: root.monthCells(root.viewYear, month.index)

                            delegate: Item {
                                required property var modelData
                                implicitWidth: modelData.type === "week" ? root.weekCell : root.cell
                                implicitHeight: root.cell

                                Label {
                                    anchors.centerIn: parent
                                    font.pixelSize: Theme.fontSize - 1

                                    visible: {
                                        let t = parent.modelData.type;
                                        if (t === "blank")
                                            return false;
                                        if (t === "day")
                                            return parent.modelData.inMonth;
                                        if (t === "week")
                                            return parent.modelData.week > 0;
                                        return true;
                                    }

                                    text: {
                                        let m = parent.modelData;
                                        if (m.type === "wd")
                                            return m.text;
                                        if (m.type === "day")
                                            return m.day;
                                        if (m.type === "week")
                                            return "W" + m.week;
                                        return "";
                                    }

                                    color: {
                                        let m = parent.modelData;
                                        if (m.type === "wd")
                                            return Theme.yellow;
                                        if (m.type === "week")
                                            return Theme.cyan;
                                        if (m.type === "day")
                                            return m.today ? Theme.pink : Theme.fgBright;
                                        return Theme.fg;
                                    }

                                    font.bold: parent.modelData.type === "day" && parent.modelData.today
                                    font.underline: parent.modelData.type === "day" && parent.modelData.today
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
