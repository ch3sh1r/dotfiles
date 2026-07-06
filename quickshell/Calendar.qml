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
    signal clicked()

    function reset() {
        viewYear = today.getFullYear();
    }
    function shiftYear(delta) {
        viewYear += delta;
    }

    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property int cell: 18
    readonly property int weekCell: 30

    function isToday(y, m, d) {
        return y === today.getFullYear() && m === today.getMonth() && d === today.getDate();
    }

    function isoWeek(d) {
        let date = new Date(d.getFullYear(), d.getMonth(), d.getDate());
        let day = date.getDay();                  // Sun=0
        date.setDate(date.getDate() - day + 4);   // Thursday of this week
        let firstThu = new Date(date.getFullYear(), 0, 4);
        let fday = firstThu.getDay();
        firstThu.setDate(firstThu.getDate() - fday + 4);
        return 1 + Math.round((date.getTime() - firstThu.getTime()) / (7 * 86400000));
    }

    // Flat 48-cell model (6 rows * (7 days + ISO week)) for one month.
    function monthCells(year, month) {
        let out = [];
        let first = new Date(year, month, 1);
        let lead = first.getDay();
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
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.clicked()
    }

    Column {
        id: col
        spacing: 10

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.viewYear
            color: Theme.purple
            font.bold: true
            font.pixelSize: Theme.menuTitleFontSize
        }

        Grid {
            columns: 2
            rowSpacing: 14
            columnSpacing: 24

            Repeater {
                model: 4

                delegate: Column {
                    id: quarter
                    required property int index
                    spacing: 0

                    Row {
                        spacing: 14

                        Repeater {
                            model: 3

                            delegate: Column {
                                id: month
                                required property int index
                                readonly property int monthIndex: quarter.index * 3 + index
                                spacing: 5

                                Label {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.monthNames[month.monthIndex]
                                    color: Theme.purple
                                    font.bold: true
                                    font.pixelSize: Theme.menuFontSize
                                }

                                Grid {
                                    columns: 8
                                    rowSpacing: 2
                                    columnSpacing: 2

                                    Repeater {
                                        model: root.monthCells(root.viewYear, month.monthIndex)

                                        delegate: Item {
                                            required property var modelData
                                            implicitWidth: modelData.type === "week" ? root.weekCell : root.cell
                                            implicitHeight: root.cell

                                            Label {
                                                anchors.centerIn: parent

                                                visible: parent.modelData.type === "day" ? parent.modelData.inMonth : parent.modelData.week > 0

                                                text: {
                                                    let m = parent.modelData;
                                                    if (m.type === "day")
                                                        return m.day;
                                                    return m.week;
                                                }

                                                color: {
                                                    let m = parent.modelData;
                                                    if (m.type === "week")
                                                        return Theme.cyan;
                                                    return m.today ? Theme.pink : Theme.fgBright;
                                                }

                                                font.bold: parent.modelData.type === "day" && parent.modelData.today
                                                font.underline: parent.modelData.type === "day" && parent.modelData.today
                                                font.pixelSize: Theme.menuFontSize
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
