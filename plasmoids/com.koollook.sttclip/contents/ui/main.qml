// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import "org/koollook/glass"

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 8

    MacOSColors {
        id: colors
        styleMode: Plasmoid.configuration.styleMode
        appearance: Plasmoid.configuration.appearance
    }

    readonly property string homeDir: {
        var u = StandardPaths.writableLocation(StandardPaths.HomeLocation).toString()
        return u.replace(/^file:\/\//, "")
    }
    readonly property string clipFile: homeDir + "/.local/state/koollook/clip.txt"
    readonly property string statusFile: homeDir + "/.local/state/koollook/status"
    readonly property string sttBin: homeDir + "/.local/bin/koollook-stt"
    property string clipText: ""
    property string listenStatus: "stopped"
    property string lastAction: ""

    function syncCommands() {
        var js = Plasmoid.configuration.commandsJson || ""
        if (js.length)
            runner.exec(sttBin + " --write-commands-json " + shellQuote(js))
    }

    function reloadClip() {
        runner.exec("cat -- " + shellQuote(clipFile) + " 2>/dev/null; echo; echo __STATUS__; cat -- " + shellQuote(statusFile) + " 2>/dev/null")
    }

    Plasma5Support.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        function exec(cmd) { connectSource(cmd) }
        onNewData: function(source, data) {
            disconnectSource(source)
            var out = data["stdout"] || ""
            if (source.indexOf("cat --") !== -1 || source.indexOf("__STATUS__") !== -1) {
                var parts = out.split("__STATUS__")
                root.clipText = (parts[0] || "").replace(/\n$/, "")
                var st = (parts[1] || "").trim()
                if (st.length)
                    root.listenStatus = st
            }
        }
    }

    Timer {
        interval: 400
        running: true
        repeat: true
        onTriggered: root.reloadClip()
    }

    function shellQuote(t) {
        return "'" + String(t).replace(/'/g, "'\\''") + "'"
    }

    Connections {
        target: Plasmoid.configuration
        function onCommandsJsonChanged() { root.syncCommands() }
    }

    Component.onCompleted: {
        syncCommands()
        reloadClip()
    }

    compactRepresentation: MouseArea {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 4
        Layout.minimumHeight: Kirigami.Units.iconSizes.small
        onClicked: root.expanded = !root.expanded
        RowLayout {
            anchors.fill: parent
            Kirigami.Icon {
                source: "audio-input-microphone"
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                color: colors.foreground
                isMask: true
            }
            PlasmaComponents.Label {
                text: root.listenStatus === "listening" ? i18n("STT") : i18n("Clip")
                color: colors.foreground
            }
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        Layout.preferredHeight: Kirigami.Units.gridUnit * 14
        Layout.minimumWidth: Kirigami.Units.gridUnit * 10
        Layout.minimumHeight: Kirigami.Units.gridUnit * 8

        LiquidGlass {
            anchors.fill: parent
            radius: Plasmoid.configuration.cornerRadius
            roundness: Plasmoid.configuration.roundnessX10 / 10
            refractThickness: Plasmoid.configuration.refractThickness
            refractIOR: Plasmoid.configuration.refractIORx100 / 100
            refractScale: Plasmoid.configuration.refractScale
            tint: colors.glassTint
            tintAlpha: Plasmoid.configuration.tintAlphaPct / 100
            chromaStrength: Plasmoid.configuration.chromaStrengthPct / 100
            specStrength: Plasmoid.configuration.specStrengthPct / 100
            blurRadius: Plasmoid.configuration.blurRadiusPx
            realtimeRefraction: Plasmoid.configuration.realtimeRefraction
            fallbackOpacity: colors.glassFallbackOpacity
            solidMode: colors.isSolid
            solidColor: colors.solidBackground
            solidColorBottom: "transparent"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Label {
                    text: i18n("STT clip")
                    font.weight: Font.DemiBold
                    color: colors.foreground
                }
                Item { Layout.fillWidth: true }
                PlasmaComponents.Label {
                    text: root.listenStatus === "listening" ? i18n("listening") : i18n("idle")
                    color: colors.foreground
                    opacity: 0.7
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
            }

            PlasmaComponents.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                PlasmaComponents.Label {
                    width: parent.width
                    wrapMode: Text.Wrap
                    text: root.clipText.length ? root.clipText : i18n("Dictate to fill this clip. Say “%1” to send, “%2” to clear.",
                        Plasmoid.configuration.sendClipPhrase || "send clip",
                        Plasmoid.configuration.deleteClipPhrase || "delete clip")
                    color: colors.foreground
                    opacity: root.clipText.length ? 1 : 0.55
                }
            }

            RowLayout {
                Layout.fillWidth: true
                PlasmaComponents.Button {
                    text: i18n("Delete clip")
                    onClicked: runner.exec(root.sttBin + " --clear-clip")
                }
                Item { Layout.fillWidth: true }
                PlasmaComponents.Button {
                    text: i18n("Send clip")
                    onClicked: runner.exec(root.sttBin + " --send-clip")
                }
            }
        }
    }
}
