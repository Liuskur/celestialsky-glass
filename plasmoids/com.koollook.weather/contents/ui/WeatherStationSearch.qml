// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

ColumnLayout {
    id: root
    spacing: Kirigami.Units.smallSpacing

    property string source: ""
    property string locationName: ""
    property string provider: "bbcukmet"
    property bool _ready: false

    Plasma5Support.DataSource {
        id: ionsSrc
        engine: "weather"
        connectedSources: ["ions"]
    }

    Plasma5Support.DataSource {
        id: valSrc
        engine: "weather"
        connectedSources: []
        onNewData: function (sourceName, data) {
            resultsModel.clear()
            if (!data)
                return
            var keys = Object.keys(data)
            var k, key, val, label
            for (k = 0; k < keys.length; k++) {
                key = keys[k]
                if (key === "validate" || key === "engine")
                    continue
                if (key.indexOf("|weather|") >= 0) {
                    val = data[key]
                    label = (typeof val === "string" && val.length) ? val : key.split("|").slice(2).join(", ")
                    resultsModel.append({ display: label, src: key })
                }
            }
            if (resultsModel.count === 0 && data["place"])
                resultsModel.append({ display: "" + data["place"], src: root.provider + "|weather|" + data["place"] })
        }
    }

    ListModel { id: resultsModel }

    function search() {
        var q = searchField.text.trim()
        if (q.length < 2)
            return
        resultsModel.clear()
        valSrc.connectedSources = [root.provider + "|validate|" + q]
    }
    ComboBox {
        id: providerBox
        Layout.fillWidth: true
        model: [i18n("BBC Weather"), i18n("NOAA"), i18n("German Weather Service"), i18n("wetter.com"), i18n("Environment Canada")]
        property var ids: ["bbcukmet", "noaa", "dwd", "wettercom", "envcan"]
        currentIndex: 0
        onActivated: function (idx) { root.provider = ids[idx] }
    }

    RowLayout {
        Layout.fillWidth: true
        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: i18n("Station or city")
            text: root.locationName
            onAccepted: root.search()
        }
        Button {
            text: i18n("Search")
            onClicked: root.search()
        }
    }

    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: Kirigami.Units.gridUnit * 8
        clip: true
        model: resultsModel
        delegate: ItemDelegate {
            width: ListView.view.width
            text: model.display
            highlighted: root.source === model.src
            onClicked: {
                root.source = model.src
                root.locationName = model.display
            }
        }
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.7
        text: root.source.length ? root.source : i18n("Same providers as Plasma Weather Report.")
        font.pointSize: Kirigami.Theme.smallFont.pointSize
    }
}
