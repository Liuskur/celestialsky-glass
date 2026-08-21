// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Layouts
import QtCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    switchWidth: Kirigami.Units.gridUnit * 8
    switchHeight: Kirigami.Units.gridUnit * 8
    preferredRepresentation: compactRepresentation

    readonly property string homeDir: {
        var u = StandardPaths.writableLocation(StandardPaths.HomeLocation).toString()
        return u.replace(/^file:\/\//, "")
    }
    readonly property string clipFile: homeDir + "/.local/state/koollook/clip.txt"
    readonly property string sttBin: homeDir + "/.local/bin/koollook-stt"
    property string clipText: ""
    property string listenStatus: "stopped"
    property string sourcesText: ""
    readonly property bool listening: listenStatus === "listening"

    Plasmoid.icon: listening ? "audio-input-microphone" : "microphone-sensitivity-muted"
    Plasmoid.status: PlasmaCore.Types.ActiveStatus
    toolTipMainText: i18n("Koollook STT")
    toolTipSubText: {
        var st = listening ? i18n("Listening") : i18n("Stopped")
        if (clipText.length)
            return st + "\n" + clipText
        return st
    }

    function shellQuote(t) {
        return "'" + String(t).replace(/'/g, "'\\''") + "'"
    }

    function reload() {
        runner.exec("cat -- " + shellQuote(clipFile) + " 2>/dev/null; echo; echo __STATUS__; " + shellQuote(sttBin) + " --status 2>/dev/null | head -1")
    }

    function start() { runner.exec(sttBin + " --start") }
    function stop() { runner.exec(sttBin + " --stop") }
    function toggle() { runner.exec(sttBin + " --toggle") }
    function sendClip() { runner.exec(sttBin + " --send-clip") }
    function deleteClip() { runner.exec(sttBin + " --clear-clip") }
    function listSources() { runner.exec(sttBin + " --list-sources") }

    Plasma5Support.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        function exec(cmd) { connectSource(cmd) }
        onNewData: function(source, data) {
            disconnectSource(source)
            var out = data["stdout"] || ""
            if (source.indexOf("--list-sources") !== -1) {
                root.sourcesText = out.trim()
                return
            }
            if (source.indexOf("__STATUS__") !== -1 || source.indexOf("cat --") !== -1) {
                var parts = out.split("__STATUS__")
                root.clipText = (parts[0] || "").replace(/\n$/, "")
                var st = (parts[1] || "").trim()
                if (st.indexOf("running") === 0)
                    root.listenStatus = "listening"
                else if (st.indexOf("stopped") === 0)
                    root.listenStatus = "stopped"
                else if (st.length)
                    root.listenStatus = st.split(/\s+/)[0]
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: root.reload()
    }

    Component.onCompleted: reload()

    PlasmaCore.Action {
        id: startAction
        text: i18n("Start listening")
        icon.name: "media-playback-start"
        enabled: !root.listening
        onTriggered: root.start()
    }
    PlasmaCore.Action {
        id: stopAction
        text: i18n("Stop listening")
        icon.name: "media-playback-stop"
        enabled: root.listening
        onTriggered: root.stop()
    }
    PlasmaCore.Action {
        id: toggleAction
        text: i18n("Toggle listening")
        icon.name: "media-playback-pause"
        onTriggered: root.toggle()
    }
    PlasmaCore.Action {
        id: sendAction
        text: i18n("Send clip")
        icon.name: "document-send"
        enabled: root.clipText.length > 0
        onTriggered: root.sendClip()
    }
    PlasmaCore.Action {
        id: deleteAction
        text: i18n("Delete clip")
        icon.name: "edit-delete"
        enabled: root.clipText.length > 0
        onTriggered: root.deleteClip()
    }

    Plasmoid.contextualActions: [startAction, stopAction, toggleAction, sendAction, deleteAction]

    compactRepresentation: MouseArea {
        id: compact
        Layout.minimumWidth: Kirigami.Units.iconSizes.small
        Layout.minimumHeight: Kirigami.Units.iconSizes.small
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        hoverEnabled: true
        property bool wasExpanded: false

        onPressed: wasExpanded = root.expanded
        onClicked: function(mouse) {
            if (mouse.button === Qt.MiddleButton)
                root.toggle()
            else
                root.expanded = !wasExpanded
        }

        Kirigami.Icon {
            anchors.fill: parent
            source: Plasmoid.icon
            active: compact.containsMouse || root.listening
        }
    }

    fullRepresentation: ColumnLayout {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 12
        Layout.preferredWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight: Kirigami.Units.gridUnit * 10
        Layout.preferredHeight: Kirigami.Units.gridUnit * 12
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.fillWidth: true
            Kirigami.Icon {
                source: Plasmoid.icon
                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
            }
            PlasmaComponents.Label {
                text: i18n("Koollook STT")
                font.weight: Font.DemiBold
            }
            Item { Layout.fillWidth: true }
            PlasmaComponents.Label {
                text: root.listening ? i18n("listening") : i18n("stopped")
                opacity: 0.7
            }
        }

        PlasmaComponents.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            PlasmaComponents.Label {
                width: parent.width
                wrapMode: Text.Wrap
                text: root.clipText.length ? root.clipText : i18n("Clip empty. Start listening, then say send clip.")
                opacity: root.clipText.length ? 1 : 0.55
            }
        }

        RowLayout {
            Layout.fillWidth: true
            PlasmaComponents.Button {
                text: root.listening ? i18n("Stop") : i18n("Start")
                icon.name: root.listening ? "media-playback-stop" : "media-playback-start"
                onClicked: root.listening ? root.stop() : root.start()
            }
            Item { Layout.fillWidth: true }
            PlasmaComponents.Button {
                text: i18n("Delete clip")
                focusPolicy: Qt.NoFocus
                enabled: root.clipText.length > 0
                onClicked: root.deleteClip()
            }
            PlasmaComponents.Button {
                text: i18n("Send clip")
                focusPolicy: Qt.NoFocus
                enabled: root.clipText.length > 0
                onClicked: root.sendClip()
            }
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Audio sources")
            icon.name: "audio-input-microphone"
            onClicked: root.listSources()
        }
        PlasmaComponents.Label {
            Layout.fillWidth: true
            visible: root.sourcesText.length > 0
            wrapMode: Text.Wrap
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.8
            text: root.sourcesText
        }
    }
}
