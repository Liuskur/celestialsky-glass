// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "engine/koollook-time.js" as KT

Item {
    id: root

    property string kind: "muhurta"
    property real latitude: 59.43696
    property real longitude: 24.75353
    property string locationName: ""
    property bool compact: false
    property color foreground: "#f4f1e8"
    property color accent: "#00d3b8"
    property color gold: "#e7bf7e"
    property color muted: "#8a9088"
    property color bad: "#c45c4a"

    property var day: null
    property var current: null
    property real frac: 0
    property string currentName: "…"
    property int periodCount: 0

    implicitWidth: compact ? Math.max(Kirigami.Units.gridUnit * 4, nameLab.implicitWidth) : Kirigami.Units.gridUnit * 16
    implicitHeight: compact ? nameLab.implicitHeight : Kirigami.Units.gridUnit * 20
    function periodAt(i) {
        if (!day || !day.periods)
            return null
        return day.periods[i]
    }

    function isHarsh(q) {
        return q === "inauspicious" || q === "fierce" || q === "heavy"
    }

    function refresh() {
        var now = new Date()
        var snap = kind === "hora"
            ? KT.horaSchedule(latitude, longitude, now)
            : KT.muhurtaSchedule(latitude, longitude, now)
        day = snap
        current = snap ? snap.current : null
        frac = KT.progress(current, now)
        currentName = current ? current.name : "…"
        periodCount = snap && snap.periods ? snap.periods.length : 0
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
    onKindChanged: refresh()
    onLatitudeChanged: refresh()
    onLongitudeChanged: refresh()

    PlasmaComponents.Label {
        visible: root.compact
        anchors.centerIn: parent
        text: root.currentName
        font.weight: Font.DemiBold
        color: root.foreground
    }

    ColumnLayout {
        visible: !root.compact
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            Layout.fillWidth: true
            text: root.locationName
            elide: Text.ElideRight
            font.weight: Font.DemiBold
            color: root.foreground
            visible: root.locationName.length > 0
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            text: root.currentName
            font.pixelSize: Kirigami.Units.gridUnit * 1.4
            font.weight: Font.DemiBold
            color: root.accent
            elide: Text.ElideRight
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: root.gold
            text: {
                if (!root.current)
                    return ""
                return root.current.meaning + " · " + root.current.quality + " · " + root.current.label
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            radius: 2
            color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.15)
            Rectangle {
                width: parent.width * root.frac
                height: parent.height
                radius: 2
                color: root.accent
            }
        }

        PlasmaComponents.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: root.muted
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            text: {
                if (!root.day)
                    return ""
                var s = i18n("Sunrise %1 · Sunset %2", root.day.sunriseLabel, root.day.sunsetLabel)
                if (root.day.dayLord)
                    s += i18n(" · Day lord %1", root.day.dayLord)
                return s
            }
        }

        Flickable {
            id: flick
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: rows.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: rows
                width: flick.width
                spacing: 1

                Repeater {
                    model: root.periodCount
                    delegate: RowLayout {
                        required property int index
                        width: rows.width
                        readonly property var p: root.periodAt(index)
                        readonly property bool here: root.current && p && p.index === root.current.index

                        PlasmaComponents.Label {
                            text: p ? String(p.index) : ""
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 1.4
                            color: here ? root.accent : root.muted
                            font.weight: here ? Font.DemiBold : Font.Normal
                        }
                        PlasmaComponents.Label {
                            text: p ? p.name : ""
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            color: here ? root.accent : root.foreground
                            font.weight: here ? Font.DemiBold : Font.Normal
                        }
                        PlasmaComponents.Label {
                            text: p ? p.quality : ""
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 6
                            elide: Text.ElideRight
                            color: p && root.isHarsh(p.quality) ? root.bad : (here ? root.accent : root.muted)
                        }
                        PlasmaComponents.Label {
                            text: p ? p.label : ""
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 6
                            horizontalAlignment: Text.AlignRight
                            color: here ? root.accent : root.muted
                        }
                    }
                }
            }
        }
    }
}
