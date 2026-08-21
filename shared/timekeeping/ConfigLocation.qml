// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../org/koollook/location"
    implicitWidth: Kirigami.Units.gridUnit * 28
    implicitHeight: Kirigami.Units.gridUnit * 18

    property string title
    property string cfg_location: ""
    property string cfg_locationDefault: ""
    property double cfg_latitude: 0
    property double cfg_latitudeDefault: 0
    property double cfg_longitude: 0
    property double cfg_longitudeDefault: 0
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

        PlasmaComponentsPlaceholder {}
    }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("Periods start at local sunrise. Glass settings are on the Appearance tab.")
        }
}
