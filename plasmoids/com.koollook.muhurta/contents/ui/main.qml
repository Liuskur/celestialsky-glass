// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "org/koollook/glass"

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    switchWidth: Kirigami.Units.gridUnit * 8
    switchHeight: Kirigami.Units.gridUnit * 6

    readonly property string boardKind: "muhurta"

    KoollookColors {
        id: colors
        styleMode: Plasmoid.configuration.styleMode
        appearance: Plasmoid.configuration.appearance
    }

    compactRepresentation: MouseArea {
        Layout.minimumWidth: compactBoard.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.minimumHeight: Kirigami.Units.iconSizes.small
        onClicked: root.expanded = !root.expanded

        TimeBoard {
            id: compactBoard
            anchors.fill: parent
            compact: true
            kind: root.boardKind
            latitude: Plasmoid.configuration.latitude
            longitude: Plasmoid.configuration.longitude
            foreground: colors.foreground
            accent: colors.koollookAccent
        }
    }

    fullRepresentation: Item {
        id: box
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        Layout.preferredHeight: Kirigami.Units.gridUnit * 22
        Layout.minimumWidth: Kirigami.Units.gridUnit * 12
        Layout.minimumHeight: Kirigami.Units.gridUnit * 12
        clip: true

        readonly property real innerPad: {
            if (Plasmoid.configuration.hideFrame)
                return Kirigami.Units.smallSpacing
            var r = Plasmoid.configuration.cornerRadius || 48
            return Math.max(Kirigami.Units.largeSpacing, Math.min(36, r * 0.22))
        }

        KoollookFrame {
            anchors.fill: parent
        }

        TimeBoard {
            anchors.fill: parent
            anchors.margins: box.innerPad
            kind: root.boardKind
            latitude: Plasmoid.configuration.latitude
            longitude: Plasmoid.configuration.longitude
            locationName: Plasmoid.configuration.location
            foreground: colors.foreground
            accent: colors.koollookAccent
            gold: colors.koollookGold
            muted: Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.65)
            bad: colors.accentRed
        }
    }
}
