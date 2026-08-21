// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.koollook.glass

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

    WeatherModel {
        id: wx
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
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        Layout.preferredHeight: Kirigami.Units.gridUnit * 16
        Layout.minimumWidth: Kirigami.Units.gridUnit * 12
        Layout.minimumHeight: Kirigami.Units.gridUnit * 10

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
                    isMask: colors.isGlass
                    color: colors.foreground
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    PlasmaComponents.Label {
                        text: wx.hasData ? wx.formatTemp(wx.temperature) : (wx.loading ? i18n("Loading…") : "—")
                        font.pixelSize: Kirigami.Units.gridUnit * 2.2
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
                wrapMode: Text.WordWrap
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

            Kirigami.Separator {
                Layout.fillWidth: true
                visible: wx.hourly.length > 0
                opacity: 0.3
            }

            ListView {
                id: hourlyView
                visible: wx.hourly.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.gridUnit * 4
                orientation: ListView.Horizontal
                clip: true
                spacing: Kirigami.Units.smallSpacing
                model: wx.hourly
                delegate: ColumnLayout {
                    width: Kirigami.Units.gridUnit * 2.4
                    spacing: 2
                    PlasmaComponents.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.label
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        color: colors.foreground
                        opacity: 0.7
                    }
                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter
                        source: modelData.icon
                        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                        isMask: colors.isGlass
                        color: colors.foreground
                    }
                    PlasmaComponents.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.temp
                        color: colors.foreground
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
                delegate: RowLayout {
                    Layout.fillWidth: true
                    PlasmaComponents.Label {
                        text: modelData.name
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                        color: colors.foreground
                    }
                    Kirigami.Icon {
                        source: modelData.icon
                        Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                        Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                        isMask: colors.isGlass
                        color: colors.foreground
                    }
                    Item { Layout.fillWidth: true }
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

            Item { Layout.fillHeight: true }
        }
    }
}
