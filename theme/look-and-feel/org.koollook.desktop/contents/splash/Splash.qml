import QtQuick

Rectangle {
    id: root
    color: "#12121a"

    property int stage: 0

    onStageChanged: {
        if (stage === 1)
            lockIn.start()
        else if (stage === 2 && !lockIn.running)
            lockIn.start()
    }

    Component.onCompleted: {
        if (stage < 1)
            lockIn.start()
    }

    Item {
        id: stageBox
        width: Math.min(parent.width, parent.height) * 0.42
        height: width
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -parent.height * 0.04

        Image {
            id: griffin
            anchors.centerIn: parent
            width: parent.width * 0.72
            height: width
            source: "images/griffin.png"
            fillMode: Image.PreserveAspectFit
            opacity: 0
            scale: 0.82
            smooth: true
        }

        Rectangle {
            id: lockFrame
            anchors.centerIn: griffin
            width: griffin.width * 1.85
            height: griffin.height * 1.85
            radius: 28
            color: "transparent"
            border.width: 2
            border.color: "#00d3b8"
            opacity: 0
        }

        Rectangle {
            id: hiLite
            anchors.fill: lockFrame
            radius: lockFrame.radius
            color: "transparent"
            border.width: 6
            border.color: "#00d3b8"
            opacity: 0
        }
    }

    SequentialAnimation {
        id: lockIn
        ParallelAnimation {
            NumberAnimation { target: griffin; property: "opacity"; to: 1; duration: 420 }
            NumberAnimation { target: griffin; property: "scale"; to: 1; duration: 640; easing.type: Easing.OutBack }
        }
        ParallelAnimation {
            NumberAnimation { target: lockFrame; property: "opacity"; to: 1; duration: 220 }
            NumberAnimation { target: lockFrame; property: "width"; to: griffin.width + 36; duration: 520; easing.type: Easing.OutCubic }
            NumberAnimation { target: lockFrame; property: "height"; to: griffin.height + 36; duration: 520; easing.type: Easing.OutCubic }
        }
        ParallelAnimation {
            NumberAnimation { target: hiLite; property: "opacity"; from: 0.55; to: 0; duration: 380 }
            NumberAnimation { target: hiLite; property: "scale"; from: 1; to: 1.12; duration: 380 }
        }
    }

    Rectangle {
        id: bar
        width: stageBox.width * 0.55
        height: 3
        radius: 1.5
        color: "#00d3b8"
        opacity: 0.85
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: stageBox.bottom
        anchors.topMargin: 28
        transformOrigin: Item.Left
        scale: 0
        SequentialAnimation on scale {
            running: true
            PauseAnimation { duration: 900 }
            NumberAnimation { from: 0; to: 1; duration: 700; easing.type: Easing.OutCubic }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 36
        text: "Koollook"
        color: "#00d3b8"
        font.pixelSize: 18
        opacity: 0.7
    }
}
