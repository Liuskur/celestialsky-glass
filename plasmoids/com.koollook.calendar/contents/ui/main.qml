// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.workspace.calendar as PlasmaCalendar
import "org/koollook/glass"

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    switchWidth: Kirigami.Units.gridUnit * 12
    switchHeight: Kirigami.Units.gridUnit * 12

    KoollookColors {
        id: colors
        styleMode: Plasmoid.configuration.styleMode
        appearance: Plasmoid.configuration.appearance
    }

    function pluginIds() {
        var p = Plasmoid.configuration.enabledCalendarPlugins
        if (p === undefined || p === null || p === "")
            return ["holidaysevents", "astronomicalevents"]
        if (typeof p === "string")
            return p.split(",").filter(function (s) { return s.length > 0 })
        var a = []
        for (var i = 0; i < p.length; i++)
            a.push(p[i])
        return a
    }

    PlasmaCalendar.EventPluginsManager {
        id: eventPlugins
        enabledPlugins: root.pluginIds()
        Component.onCompleted: populateEnabledPluginsList(root.pluginIds())
    }

    Connections {
        target: Plasmoid.configuration
        function onEnabledCalendarPluginsChanged() {
            eventPlugins.enabledPlugins = root.pluginIds()
            eventPlugins.populateEnabledPluginsList(root.pluginIds())
        }
    }

    fullRepresentation: Item {
        id: calRoot
        Layout.preferredWidth: Kirigami.Units.gridUnit * 22
        Layout.preferredHeight: Kirigami.Units.gridUnit * 20
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 14
        clip: true

        KoollookFrame {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.max(Kirigami.Units.largeSpacing,
                Plasmoid.configuration.hideFrame ? Kirigami.Units.smallSpacing
                    : Math.min(28, (Plasmoid.configuration.cornerRadius || 48) * 0.18))
            spacing: Kirigami.Units.smallSpacing
            clip: true

            PlasmaCalendar.MonthView {
                id: monthView
                Layout.fillWidth: true
                Layout.fillHeight: true
                today: new Date()
                showWeekNumbers: Plasmoid.configuration.showWeekNumbers
                firstDayOfWeek: Plasmoid.configuration.firstDayOfWeek
                eventPluginsManager: eventPlugins
                Component.onCompleted: {
                    if (daysModel)
                        daysModel.setPluginsManager(eventPlugins)
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                opacity: 0.35
                visible: eventList.count > 0
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                visible: eventList.count > 0
                text: monthView.currentDate
                    ? Qt.locale().toString(monthView.currentDate, Locale.LongFormat)
                    : ""
                color: colors.foreground
                font.weight: Font.DemiBold
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                elide: Text.ElideRight
            }

            ListView {
                id: eventList
                Layout.fillWidth: true
                Layout.preferredHeight: eventList.count > 0 ? Kirigami.Units.gridUnit * 4.2 : 0
                clip: true
                spacing: 2
                model: {
                    var d = monthView.currentDate
                    if (!d)
                        d = new Date()
                    var ev = eventPlugins.eventsForDate(d)
                    return ev || []
                }
                delegate: PlasmaComponents.ItemDelegate {
                    width: ListView.view.width
                    height: Kirigami.Units.gridUnit * 1.35
                    contentItem: RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Rectangle {
                            Layout.preferredWidth: 4
                            Layout.preferredHeight: parent.height - 4
                            radius: 2
                            color: modelData.eventColor || colors.todayAccent
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                text: modelData.title || ""
                                elide: Text.ElideRight
                                color: colors.foreground
                            }
                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                visible: (modelData.isAllDay === true) || (modelData.title || "").length > 0
                                text: modelData.isAllDay ? i18n("All day") : ""
                                color: colors.foreground
                                opacity: 0.6
                                font.pointSize: Kirigami.Theme.smallFont.pointSize
                            }
                        }
                    }
                }

                PlasmaComponents.Label {
                    anchors.centerIn: parent
                    visible: eventList.count === 0
                    text: i18n("No events")
                    color: colors.foreground
                    opacity: 0.4
                }
            }
        }
    }
}
