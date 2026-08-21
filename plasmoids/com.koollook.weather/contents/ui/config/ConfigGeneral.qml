// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import ".."

Item {
    id: root
    implicitWidth: Kirigami.Units.gridUnit * 28
    implicitHeight: Kirigami.Units.gridUnit * 28

    property string title
    property string cfg_location: ""
    property string cfg_locationDefault: ""
    property string cfg_source: ""
    property string cfg_sourceDefault: ""
    property string cfg_provider: "bbcukmet"
    property string cfg_providerDefault: "bbcukmet"
    property string cfg_placeInfo: ""
    property string cfg_placeInfoDefault: ""
    property double cfg_latitude: 0
    property int cfg_temperatureUnit: 0
    property int cfg_temperatureUnitDefault: 0
    property var cfg_styleMode
    property var cfg_styleModeDefault
    property var cfg_appearance
    property var cfg_appearanceDefault
    property var cfg_cornerRadius
    property var cfg_cornerRadiusDefault
    property var cfg_roundnessX10
    property var cfg_roundnessX10Default
    property var cfg_refractThickness
    property var cfg_refractThicknessDefault
    property var cfg_refractIORx100
    property var cfg_refractIORx100Default
    property var cfg_refractScale
    property var cfg_refractScaleDefault
    property var cfg_tintAlphaPct
    property var cfg_tintAlphaPctDefault
    property var cfg_chromaStrengthPct
    property var cfg_chromaStrengthPctDefault
    property var cfg_specStrengthPct
    property var cfg_specStrengthPctDefault
    property var cfg_blurRadiusPx
    property var cfg_blurRadiusPxDefault
    property var cfg_realtimeRefraction
    property var cfg_realtimeRefractionDefault
    property var cfg_hideFrame
    property var cfg_hideFrameDefault
    property bool _ready: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing * 2
        spacing: Kirigami.Units.largeSpacing
        WeatherStationSearch {
            id: loc
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: root.cfg_source
            locationName: root.cfg_location
            latitude: root.cfg_latitude
            longitude: root.cfg_longitude
            provider: root.cfg_provider
            onSourceChanged: if (root._ready) {
                root.cfg_source = source
                var p = source.split("|")
                if (p.length)
                    root.cfg_provider = p[0]
                if (p.length >= 3)
                    root.cfg_placeInfo = p.slice(2).join("|")
            }
            onLocationNameChanged: if (root._ready) root.cfg_location = locationName
            onLatitudeChanged: if (root._ready) root.cfg_latitude = latitude
            onLongitudeChanged: if (root._ready) root.cfg_longitude = longitude
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true
            ComboBox {
                id: unitCombo
                Kirigami.FormData.label: i18n("Temperature:")
                model: [i18n("Celsius"), i18n("Fahrenheit")]
                currentIndex: Math.max(0, Math.min(count - 1, root.cfg_temperatureUnit))
                onActivated: function(idx) { root.cfg_temperatureUnit = idx }
            }
        }
    }

    Component.onCompleted: _ready = true
}
