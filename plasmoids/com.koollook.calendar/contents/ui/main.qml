// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.workspace.calendar as PlasmaCalendar
import "org/koollook/glass"

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    switchWidth: Kirigami.Units.gridUnit * 12
    switchHeight: Kirigami.Units.gridUnit * 12

    MacOSColors {
        id: colors
        styleMode: Plasmoid.configuration.styleMode
        appearance: Plasmoid.configuration.appearance
    }

    PlasmaCalendar.EventPluginsManager {
        id: eventPlugins
        Component.onCompleted: populateEnabledPluginsList(Plasmoid.configuration.enabledCalendarPlugins)
    }

    Connections {
        target: Plasmoid.configuration
        function onEnabledCalendarPluginsChanged() {
            eventPlugins.populateEnabledPluginsList(Plasmoid.configuration.enabledCalendarPlugins)
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 21
        Layout.preferredHeight: Kirigami.Units.gridUnit * 16
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 12

        LiquidGlass {
            id: glass
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

        PlasmaCalendar.MonthView {
            id: monthView
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            today: new Date()
            showWeekNumbers: Plasmoid.configuration.showWeekNumbers
            firstDayOfWeek: Plasmoid.configuration.firstDayOfWeek
            eventPluginsManager: eventPlugins
        }
    }
}
