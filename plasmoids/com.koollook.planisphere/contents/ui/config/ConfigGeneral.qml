// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../org/koollook/location"

Item {
    id: root
    implicitWidth: Kirigami.Units.gridUnit * 28
    implicitHeight: Kirigami.Units.gridUnit * 22

    property string title
    property string cfg_location: ""
    property string cfg_locationDefault: ""
    property double cfg_latitude: 0
    property double cfg_latitudeDefault: 0
    property double cfg_longitude: 0
    property double cfg_longitudeDefault: 0
    property double cfg_planetScale: 1.8
    property double cfg_planetScaleDefault: 1.8
    property double cfg_bgOpacity: 0
    property double cfg_bgOpacityDefault: 0
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
        id: content
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing * 2
        spacing: Kirigami.Units.largeSpacing

        LocationSearch {
            id: loc
            Layout.fillWidth: true
            locationName: root.cfg_location
            latitude: root.cfg_latitude
            longitude: root.cfg_longitude
            onLocationNameChanged: if (root._ready) root.cfg_location = locationName
            onLatitudeChanged: if (root._ready) root.cfg_latitude = latitude
            onLongitudeChanged: if (root._ready) root.cfg_longitude = longitude
        }

        Kirigami.Separator { Layout.fillWidth: true }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            SpinBox {
                id: planetScaleSpin
                Kirigami.FormData.label: i18n("Planet size (×10):")
                from: 5
                to: 30
                stepSize: 1
                onValueChanged: {
                    if (root._ready)
                        root.cfg_planetScale = value / 10.0
                }
            }

            SpinBox {
                id: bgOpacitySpin
                Kirigami.FormData.label: i18n("Canvas fill (%):")
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    if (root._ready)
                        root.cfg_bgOpacity = value / 100.0
                }
            }
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("Search sets latitude and longitude. Glass settings are on the Appearance tab — Copy/Paste style to match Calendar and Weather.")
        }
    }

    Component.onCompleted: {
        planetScaleSpin.value = Math.round(cfg_planetScale * 10)
        bgOpacitySpin.value = Math.round(cfg_bgOpacity * 100)
        _ready = true
    }
}
