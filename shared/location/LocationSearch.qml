// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    spacing: Kirigami.Units.smallSpacing

    property string locationName: ""
    property real latitude: 0
    property real longitude: 0
    property bool showHeading: true

    property int _reqId: 0
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

    function applyPick(name, lat, lon, display) {
        locationName = name
        latitude = lat
        longitude = lon
        locationField.text = display || name
        suggestionsPopup.close()
    }

    Label {
        visible: root.showHeading
        Layout.fillWidth: true
        text: i18n("Location")
        font.bold: true
    }

    TextField {
        id: locationField
        Layout.fillWidth: true
        text: root.locationName
        placeholderText: i18n("City name…")
        onTextEdited: {
            root.locationName = text
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
                onClicked: root.applyPick(model.name, model.latitude, model.longitude, model.display)
            }
        }
    }

    Kirigami.FormLayout {
        Layout.fillWidth: true
        Label {
            Kirigami.FormData.label: i18n("Latitude:")
            text: Number(root.latitude).toFixed(5)
        }
        Label {
            Kirigami.FormData.label: i18n("Longitude:")
            text: Number(root.longitude).toFixed(5)
        }
    }
}
