import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root
    implicitWidth: content.implicitWidth + Kirigami.Units.largeSpacing * 4
    implicitHeight: content.implicitHeight + Kirigami.Units.largeSpacing * 4

    property string cfg_location: ""
    property double cfg_latitude: 0
    property double cfg_longitude: 0
    property double cfg_planetScale: 1.8
    property double cfg_bgOpacity: 0

    property int _reqId: 0
    property bool _ready: false

    ListModel { id: suggestionsModel }

    Timer {
        id: searchDebounce
        interval: 250
        repeat: false
        onTriggered: root._search(locationField.text)
    }

    function _search(query) {
        var q = (query || "").trim()
        if (q.length < 2) {
            suggestionsModel.clear()
            suggestionsPopup.close()
            return
        }
        var reqId = ++_reqId
        var xhr = new XMLHttpRequest()
        var url = "https://geocoding-api.open-meteo.com/v1/search?name=" +
                  encodeURIComponent(q) + "&count=8&language=en&format=json"
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (reqId !== root._reqId) return
            if (xhr.status !== 200) return
            try {
                var resp = JSON.parse(xhr.responseText)
                suggestionsModel.clear()
                if (!resp.results || resp.results.length === 0) {
                    suggestionsPopup.close()
                    return
                }
                for (var i = 0; i < resp.results.length; i++) {
                    var r = resp.results[i]
                    var parts = [r.name]
                    if (r.admin1 && r.admin1.length > 0) parts.push(r.admin1)
                    if (r.country && r.country.length > 0) parts.push(r.country)
                    suggestionsModel.append({
                        display: parts.join(", "),
                        name: r.name || "",
                        latitude: r.latitude,
                        longitude: r.longitude
                    })
                }
                if (locationField.activeFocus)
                    suggestionsPopup.open()
            } catch (e) {}
        }
        xhr.open("GET", url)
        xhr.send()
    }

    Component.onCompleted: {
        planetScaleSpin.value = Math.round(cfg_planetScale * 10)
        bgOpacitySpin.value = Math.round(cfg_bgOpacity * 100)
        _ready = true
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing * 2
        spacing: Kirigami.Units.largeSpacing

        Label {
            Layout.fillWidth: true
            text: i18n("Location")
            font.bold: true
        }

        TextField {
            id: locationField
            Layout.fillWidth: true
            text: root.cfg_location
            placeholderText: i18n("City name…")
            onTextEdited: {
                root.cfg_location = text
                searchDebounce.restart()
            }
            onActiveFocusChanged: {
                if (!activeFocus)
                    suggestionsPopup.close()
            }
            Keys.onDownPressed: {
                if (suggestionsPopup.opened && suggestionsModel.count > 0)
                    suggestionList.forceActiveFocus()
            }
        }

        Popup {
            id: suggestionsPopup
            parent: locationField
            y: locationField.height
            width: locationField.width
            padding: 0
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            contentItem: ListView {
                id: suggestionList
                clip: true
                implicitHeight: Math.min(contentHeight, Kirigami.Units.gridUnit * 12)
                model: suggestionsModel
                delegate: ItemDelegate {
                    width: suggestionList.width
                    text: model.display
                    onClicked: {
                        root.cfg_location = model.name
                        root.cfg_latitude = model.latitude
                        root.cfg_longitude = model.longitude
                        locationField.text = model.display
                        suggestionsPopup.close()
                    }
                }
            }
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true

            Label {
                Kirigami.FormData.label: i18n("Latitude:")
                text: Number(root.cfg_latitude).toFixed(5)
            }
            Label {
                Kirigami.FormData.label: i18n("Longitude:")
                text: Number(root.cfg_longitude).toFixed(5)
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

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
            text: i18n("Search picks coordinates like the Weather widget. Glass settings are on the Appearance tab — use Copy/Paste style to match Calendar & Weather.")
        }
    }
}
