// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "org/koollook/location"

ColumnLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing

    property string cfg_location
    property double cfg_latitude
    property double cfg_longitude
    property alias cfg_temperatureUnit: unitCombo.currentIndex
    property bool _ready: false

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

    Kirigami.FormLayout {
        Layout.fillWidth: true
        ComboBox {
            id: unitCombo
            Kirigami.FormData.label: i18n("Temperature:")
            model: [i18n("Celsius"), i18n("Fahrenheit")]
        }
    }

    Component.onCompleted: _ready = true
}
