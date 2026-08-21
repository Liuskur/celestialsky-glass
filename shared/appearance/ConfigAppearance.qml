import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root
    implicitWidth: Kirigami.Units.gridUnit * 32
    implicitHeight: Kirigami.Units.gridUnit * 42

    property string title

    property int cfg_styleMode: 0
    property int cfg_styleModeDefault: 0
    property int cfg_appearance: 0
    property int cfg_appearanceDefault: 0
    property int cfg_cornerRadius: 64
    property int cfg_cornerRadiusDefault: 64
    property int cfg_roundnessX10: 75
    property int cfg_roundnessX10Default: 75
    property int cfg_refractThickness: 35
    property int cfg_refractThicknessDefault: 35
    property int cfg_refractIORx100: 170
    property int cfg_refractIORx100Default: 170
    property int cfg_refractScale: 65
    property int cfg_refractScaleDefault: 65
    property int cfg_tintAlphaPct: 22
    property int cfg_tintAlphaPctDefault: 22
    property int cfg_chromaStrengthPct: 28
    property int cfg_chromaStrengthPctDefault: 28
    property int cfg_specStrengthPct: 70
    property int cfg_specStrengthPctDefault: 70
    property int cfg_blurRadiusPx: 2
    property int cfg_blurRadiusPxDefault: 2
    property bool cfg_realtimeRefraction: false
    property bool cfg_realtimeRefractionDefault: false
    property bool cfg_hideFrame: false
    property bool cfg_hideFrameDefault: false

    property var cfg_location
    property var cfg_locationDefault
    property var cfg_latitude
    property var cfg_latitudeDefault
    property var cfg_longitude
    property var cfg_longitudeDefault
    property var cfg_planetScale
    property var cfg_planetScaleDefault
    property var cfg_bgOpacity
    property var cfg_bgOpacityDefault
    property var cfg_temperatureUnit
    property var cfg_temperatureUnitDefault
    property var cfg_enabledCalendarPlugins
    property var cfg_enabledCalendarPluginsDefault
    property var cfg_firstDayOfWeek
    property var cfg_firstDayOfWeekDefault
    property var cfg_showWeekNumbers
    property var cfg_showWeekNumbersDefault
    property var cfg_eventLookaheadDays
    property var cfg_eventLookaheadDaysDefault
    property var cfg_deleteClipPhrase
    property var cfg_deleteClipPhraseDefault
    property var cfg_sendClipPhrase
    property var cfg_sendClipPhraseDefault
    property var cfg_commandsJson
    property var cfg_commandsJsonDefault
    property var cfg_sourceMode
    property var cfg_sourceModeDefault
    property var cfg_barCount
    property var cfg_barCountDefault
    property var cfg_sensitivity
    property var cfg_sensitivityDefault
    property var cfg_innerRadiusPct
    property var cfg_innerRadiusPctDefault
    property var cfg_source
    property var cfg_sourceDefault
    property var cfg_provider
    property var cfg_providerDefault
    property var cfg_placeInfo
    property var cfg_placeInfoDefault

    function _serialize() {
        return JSON.stringify({
            s: cfg_styleMode,
            a: cfg_appearance,
            cr: cfg_cornerRadius,
            rn: cfg_roundnessX10,
            rt: cfg_refractThickness,
            ri: cfg_refractIORx100,
            rs: cfg_refractScale,
            ta: cfg_tintAlphaPct,
            ca: cfg_chromaStrengthPct,
            ss: cfg_specStrengthPct,
            br: cfg_blurRadiusPx,
            rr: cfg_realtimeRefraction,
            hf: cfg_hideFrame
        })
    }

    function _deserialize(text) {
        try {
            var o = JSON.parse(text)
            if (o.s  !== undefined) cfg_styleMode = o.s
            if (o.a  !== undefined) cfg_appearance = o.a
            if (o.cr !== undefined) cfg_cornerRadius = o.cr
            if (o.rn !== undefined) cfg_roundnessX10 = o.rn
            if (o.rt !== undefined) cfg_refractThickness = o.rt
            if (o.ri !== undefined) cfg_refractIORx100 = o.ri
            if (o.rs !== undefined) cfg_refractScale = o.rs
            if (o.ta !== undefined) cfg_tintAlphaPct = o.ta
            if (o.ca !== undefined) cfg_chromaStrengthPct = o.ca
            if (o.ss !== undefined) cfg_specStrengthPct = o.ss
            if (o.br !== undefined) cfg_blurRadiusPx = o.br
            if (o.rr !== undefined) cfg_realtimeRefraction = o.rr
            if (o.hf !== undefined) cfg_hideFrame = o.hf
            pasteStatus.text = i18n("Applied!")
        } catch (e) {
            pasteStatus.text = i18n("Invalid config string")
        }
        pasteStatus.visible = true
        statusTimer.restart()
    }

    Timer {
        id: statusTimer
        interval: 3000
        onTriggered: pasteStatus.visible = false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            RowLayout {
                Kirigami.FormData.label: i18n("Preset:")
                spacing: Kirigami.Units.smallSpacing

                Button {
                    icon.name: "edit-copy"
                    text: i18n("Copy style")
                    onClicked: {
                        _hiddenField.text = root._serialize()
                        _hiddenField.selectAll()
                        _hiddenField.copy()
                        pasteStatus.text = i18n("Copied!")
                        pasteStatus.visible = true
                        statusTimer.restart()
                    }
                }

                Button {
                    icon.name: "edit-paste"
                    text: i18n("Paste style")
                    onClicked: {
                        _hiddenField.text = ""
                        _hiddenField.paste()
                        root._deserialize(_hiddenField.text)
                    }
                }
            }

            TextField { id: _hiddenField; visible: false }

            Label {
                id: pasteStatus
                visible: false
                font.italic: true
                opacity: 0.7
            }

            ComboBox {
                id: styleCombo
                Kirigami.FormData.label: i18n("Style:")
                model: [
                    i18n("Glass"),
                    i18n("Solid"),
                    i18n("Clear (see-through)"),
                    i18n("Plasma"),
                    i18n("Chameleon"),
                    i18n("Inverse"),
                    i18n("Koollook")
                ]
                currentIndex: Math.max(0, Math.min(count - 1, root.cfg_styleMode))
                onActivated: function(idx) { root.cfg_styleMode = idx }
            }

            ComboBox {
                id: appearanceCombo
                Kirigami.FormData.label: i18n("Appearance:")
                model: [i18n("Dark"), i18n("Light"), i18n("Follow system")]
                currentIndex: Math.max(0, Math.min(count - 1, root.cfg_appearance))
                onActivated: function(idx) { root.cfg_appearance = idx }
            }

            CheckBox {
                id: hideFrameCheck
                Kirigami.FormData.label: i18n("Frame:")
                text: i18n("No borders / invisible frame")
                checked: root.cfg_hideFrame
                onToggled: root.cfg_hideFrame = checked
            }

            SpinBox {
                id: radiusSpin
                Kirigami.FormData.label: i18n("Corner radius (px):")
                from: 0; to: 200; stepSize: 1
                value: root.cfg_cornerRadius
                onValueModified: root.cfg_cornerRadius = value
                visible: !root.cfg_hideFrame && root.cfg_styleMode !== 2
            }

            SpinBox {
                id: roundnessSpin
                Kirigami.FormData.label: i18n("Roundness (×10, 2.0..10.0):")
                from: 20; to: 100; stepSize: 1
                value: root.cfg_roundnessX10
                onValueModified: root.cfg_roundnessX10 = value
                visible: !root.cfg_hideFrame && root.cfg_styleMode !== 2
            }
        }

        Kirigami.FormLayout {
            Layout.fillWidth: true
            visible: root.cfg_styleMode === 0 || root.cfg_styleMode === 4 || root.cfg_styleMode === 6

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Glass effect")
            }

            SpinBox {
                Kirigami.FormData.label: i18n("Refraction thickness (px):")
                from: 1; to: 80; stepSize: 1
                value: root.cfg_refractThickness
                onValueModified: root.cfg_refractThickness = value
            }
            SpinBox {
                Kirigami.FormData.label: i18n("Index of refraction (×100):")
                from: 100; to: 400; stepSize: 5
                value: root.cfg_refractIORx100
                onValueModified: root.cfg_refractIORx100 = value
            }
            SpinBox {
                Kirigami.FormData.label: i18n("Refraction strength:")
                from: 0; to: 300; stepSize: 5
                value: root.cfg_refractScale
                onValueModified: root.cfg_refractScale = value
            }
            SpinBox {
                Kirigami.FormData.label: i18n("Tint alpha (%):")
                from: 0; to: 100; stepSize: 1
                value: root.cfg_tintAlphaPct
                onValueModified: root.cfg_tintAlphaPct = value
            }
            SpinBox {
                Kirigami.FormData.label: i18n("Chromatic aberration (%):")
                from: 0; to: 100; stepSize: 1
                value: root.cfg_chromaStrengthPct
                onValueModified: root.cfg_chromaStrengthPct = value
            }
            SpinBox {
                Kirigami.FormData.label: i18n("Specular strength (%):")
                from: 0; to: 100; stepSize: 5
                value: root.cfg_specStrengthPct
                onValueModified: root.cfg_specStrengthPct = value
            }
            SpinBox {
                Kirigami.FormData.label: i18n("Blur radius (px):")
                from: 0; to: 100; stepSize: 1
                value: root.cfg_blurRadiusPx
                onValueModified: root.cfg_blurRadiusPx = value
            }
            CheckBox {
                Kirigami.FormData.label: i18n("Realtime refraction:")
                text: i18n("Recapture every frame (enable for video wallpapers)")
                checked: root.cfg_realtimeRefraction
                onToggled: root.cfg_realtimeRefraction = checked
            }
        }
    }
}
