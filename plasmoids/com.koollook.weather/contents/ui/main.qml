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
    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 8

    KoollookColors {
        id: colors
        styleMode: Plasmoid.configuration.styleMode
        appearance: Plasmoid.configuration.appearance
    }

    WeatherModel {
        id: wx
        source: {
            var s = Plasmoid.configuration.source || ""
            if (!s.length || s === "bbcukmet|weather|Tallinn, Estonia|588409")
                return "openmeteo"
            return s
        }
        latitude: Plasmoid.configuration.latitude
        longitude: Plasmoid.configuration.longitude
        temperatureUnit: Plasmoid.configuration.temperatureUnit
    }

    Timer {
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        onTriggered: wx.refresh()
    }
    Connections {
        target: Plasmoid.configuration
        function onSourceChanged() { wx.refresh() }
        function onLatitudeChanged() { wx.refresh() }
        function onLongitudeChanged() { wx.refresh() }
        function onTemperatureUnitChanged() { wx.refresh() }
    }

    Component.onCompleted: wx.refresh()

    compactRepresentation: MouseArea {
        Layout.minimumWidth: compactRow.implicitWidth
        Layout.minimumHeight: Kirigami.Units.iconSizes.small
        onClicked: root.expanded = !root.expanded

        RowLayout {
            id: compactRow
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing
            Kirigami.Icon {
                source: wx.iconName
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
            }
            PlasmaComponents.Label {
                text: wx.hasData ? wx.formatTemp(wx.temperature) : "…"
                font.weight: Font.DemiBold
            }
        }
    }

    fullRepresentation: Item {
        id: weatherRoot
        Layout.preferredWidth: Kirigami.Units.gridUnit * 22
        Layout.preferredHeight: Kirigami.Units.gridUnit * 22
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 14
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

        ColumnLayout {
            id: weatherBody
            anchors.fill: parent
            anchors.margins: weatherRoot.innerPad
            spacing: Kirigami.Units.smallSpacing
            clip: true

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: Plasmoid.configuration.location
                elide: Text.ElideRight
                font.weight: Font.DemiBold
                color: colors.foreground
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Icon {
                    source: wx.iconName
                    Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                    Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                    isMask: colors.useLightGlyphs
                    color: colors.foreground
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    PlasmaComponents.Label {
                        text: wx.hasData ? wx.formatTemp(wx.temperature) : (wx.loading ? i18n("Loading…") : "—")
                        font.pixelSize: Kirigami.Units.gridUnit * 2.0
                        font.weight: Font.Light
                        color: colors.foreground
                    }
                    PlasmaComponents.Label {
                        text: wx.conditionText
                        color: colors.foreground
                        opacity: 0.85
                    }
                    PlasmaComponents.Label {
                        visible: wx.hasData
                        text: i18n("Feels like %1", wx.formatTemp(wx.feelsLike))
                        color: colors.foreground
                        opacity: 0.7
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                    }
                }
            }

            PlasmaComponents.Label {
                visible: wx.error.length > 0
                Layout.fillWidth: true
                text: wx.error
                wrapMode: Text.Wrap
                color: colors.foreground
            }

            RowLayout {
                Layout.fillWidth: true
                visible: wx.hasData
                spacing: Kirigami.Units.largeSpacing

                PlasmaComponents.Label {
                    text: i18n("Wind %1 %2 m/s", wx.windArrow(), Math.round(wx.windSpeed))
                    color: colors.foreground
                    opacity: 0.8
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
                PlasmaComponents.Label {
                    text: i18n("Humidity %1%", Math.round(wx.humidity))
                    color: colors.foreground
                    opacity: 0.8
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
                PlasmaComponents.Label {
                    text: i18n("%1 hPa", Math.round(wx.pressure))
                    color: colors.foreground
                    opacity: 0.8
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: wx.hourly.length > 0
                Repeater {
                    model: ["06", "09", "12", "15", "18", "21"]
                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        color: colors.foreground
                        opacity: 0.45
                    }
                }
            }

            ListView {
                id: hourlyView
                visible: wx.hourly.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 3.6
                orientation: ListView.Horizontal
                clip: true
                spacing: 0
                model: wx.hourly
                delegate: Item {
                    width: Math.max(Kirigami.Units.gridUnit * 2.2, hourlyView.width / Math.max(1, hourlyView.count))
                    height: hourlyView.height
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2
                        PlasmaComponents.Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.label
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            color: colors.foreground
                            opacity: 0.7
                        }
                        Kirigami.Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: modelData.icon
                            width: Kirigami.Units.iconSizes.smallMedium
                            height: width
                            isMask: colors.useLightGlyphs
                            color: colors.foreground
                        }
                        PlasmaComponents.Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.temp
                            color: colors.foreground
                        }
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
                visible: wx.daily.length > 0
                opacity: 0.3
            }

            Repeater {
                model: wx.daily
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        PlasmaComponents.Label {
                            text: modelData.name
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 2.6
                            color: colors.foreground
                            font.weight: Font.DemiBold
                        }
                        Repeater {
                            model: modelData.slots
                            Kirigami.Icon {
                                source: modelData.icon
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                Layout.fillWidth: true
                                isMask: colors.useLightGlyphs
                                color: colors.foreground
                            }
                        }
                        PlasmaComponents.Label {
                            text: modelData.high
                            color: colors.foreground
                            font.weight: Font.DemiBold
                        }
                        PlasmaComponents.Label {
                            text: modelData.low
                            color: colors.foreground
                            opacity: 0.65
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
