// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents

Item {
    id: card
    property string title: ""
    property string timeLabel: ""
    property color pillColor: "#4B9EFF"
    property color textColor: "#ffffff"

    implicitHeight: KirigamiUnits.row
    height: implicitHeight

    QtObject {
        id: KirigamiUnits
        readonly property int row: 22
    }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: textColor
        opacity: 0.08
    }

    Rectangle {
        id: pill
        width: 3
        radius: 1.5
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        color: card.pillColor
    }

    PlasmaComponents.Label {
        anchors.left: pill.right
        anchors.leftMargin: 8
        anchors.right: timeTxt.left
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        text: card.title
        elide: Text.ElideRight
        color: card.textColor
    }

    PlasmaComponents.Label {
        id: timeTxt
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: card.timeLabel
        color: card.textColor
        opacity: 0.55
        font.pointSize: KirigamiTheme.small
    }

    QtObject {
        id: KirigamiTheme
        readonly property int small: 9
    }
}
