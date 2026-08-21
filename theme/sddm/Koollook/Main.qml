import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#12121a"

    Image {
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
    }

    Item {
        id: stageBox
        width: Math.min(parent.width, parent.height) * 0.28
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -parent.height * 0.16

        Image {
            id: griffin
            anchors.centerIn: parent
            width: parent.width * 0.78
            height: width
            source: "griffin.png"
            fillMode: Image.PreserveAspectFit
            opacity: 0
            scale: 0.84
        }

        Rectangle {
            id: lockFrame
            anchors.centerIn: griffin
            width: griffin.width * 1.8
            height: griffin.height * 1.8
            radius: 22
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
            border.width: 5
            border.color: "#00d3b8"
            opacity: 0
        }
    }

    SequentialAnimation {
        id: lockIn
        running: true
        ParallelAnimation {
            NumberAnimation { target: griffin; property: "opacity"; to: 1; duration: 400 }
            NumberAnimation { target: griffin; property: "scale"; to: 1; duration: 620; easing.type: Easing.OutBack }
        }
        ParallelAnimation {
            NumberAnimation { target: lockFrame; property: "opacity"; to: 1; duration: 200 }
            NumberAnimation { target: lockFrame; property: "width"; to: griffin.width + 32; duration: 500; easing.type: Easing.OutCubic }
            NumberAnimation { target: lockFrame; property: "height"; to: griffin.height + 32; duration: 500; easing.type: Easing.OutCubic }
        }
        NumberAnimation { target: hiLite; property: "opacity"; from: 0.5; to: 0; duration: 360 }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: stageBox.bottom
        anchors.topMargin: 36
        spacing: 12
        width: 280

        TextField {
            id: user
            width: parent.width
            placeholderText: "User"
            text: typeof userModel !== "undefined" && userModel.lastUser ? userModel.lastUser : ""
            color: "#e7bf7e"
            placeholderTextColor: "#66706c"
            background: Rectangle { color: "#1d1d27"; border.color: "#00d3b8"; border.width: 1; radius: 6 }
            KeyNavigation.tab: pass
            onAccepted: pass.forceActiveFocus()
        }
        TextField {
            id: pass
            width: parent.width
            placeholderText: "Password"
            echoMode: TextInput.Password
            color: "#e7bf7e"
            placeholderTextColor: "#66706c"
            background: Rectangle { color: "#1d1d27"; border.color: "#00d3b8"; border.width: 1; radius: 6 }
            onAccepted: loginBtn.clicked()
        }
        Button {
            id: loginBtn
            width: parent.width
            text: "Log in"
            contentItem: Text { text: loginBtn.text; color: "#12121a"; horizontalAlignment: Text.AlignHCenter; anchors.centerIn: parent }
            background: Rectangle { color: "#00d3b8"; radius: 6 }
            onClicked: {
                if (typeof sddm !== "undefined")
                    sddm.login(user.text, pass.text, sessionCombo.currentIndex)
            }
        }
        ComboBox {
            id: sessionCombo
            width: parent.width
            model: typeof sessionModel !== "undefined" ? sessionModel : ["plasma"]
            visible: typeof sessionModel !== "undefined"
        }
        Text {
            id: err
            width: parent.width
            color: "#ff6b6b"
            wrapMode: Text.Wrap
            Connections {
                target: typeof sddm !== "undefined" ? sddm : null
                function onLoginFailed() { err.text = "Login failed" }
            }
        }
    }
}
