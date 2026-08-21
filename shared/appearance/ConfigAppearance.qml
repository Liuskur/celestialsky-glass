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
    property var cfg_commandsJson
    property var cfg_commandsJsonDefault
    property var cfg_sendClipPhrase
    property var cfg_sendClipPhraseDefault
    property var cfg_deleteClipPhrase
    property var cfg_deleteClipPhraseDefault
            ri: iorSpin.value,
            rs: scaleSpin.value,
            ta: tintSpin.value,
            ca: chromaSpin.value,
            ss: specStrengthSpin.value,
            br: blurRadiusSpin.value,
            rr: realtimeCheck.checked,
            hf: hideFrameCheck.checked
        })
    }

    function _deserialize(text) {
        try {
            var o = JSON.parse(text)
            if (o.s  !== undefined) styleCombo.currentIndex      = o.s
            if (o.a  !== undefined) appearanceCombo.currentIndex  = o.a
            if (o.cr !== undefined) radiusSpin.value              = o.cr
            if (o.rn !== undefined) roundnessSpin.value           = o.rn
            if (o.rt !== undefined) thicknessSpin.value           = o.rt
            if (o.ri !== undefined) iorSpin.value                 = o.ri
            if (o.rs !== undefined) scaleSpin.value               = o.rs
            if (o.ta !== undefined) tintSpin.value                = o.ta
            if (o.ca !== undefined) chromaSpin.value              = o.ca
            if (o.ss !== undefined) specStrengthSpin.value        = o.ss
            if (o.br !== undefined) blurRadiusSpin.value          = o.br
            if (o.rr !== undefined) realtimeCheck.checked         = o.rr
            if (o.hf !== undefined) hideFrameCheck.checked        = o.hf
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

        TextField {
            id: _hiddenField
            visible: false
        }

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
        }

        ComboBox {
            id: appearanceCombo
            Kirigami.FormData.label: i18n("Appearance:")
            model: [i18n("Dark"), i18n("Light"), i18n("Follow system")]
        }

        CheckBox {
            id: hideFrameCheck
            Kirigami.FormData.label: i18n("Frame:")
            text: i18n("No borders / invisible frame")
        }

        SpinBox {
            id: radiusSpin
            Kirigami.FormData.label: i18n("Corner radius (px):")
            from: 0; to: 200; stepSize: 1
            visible: !hideFrameCheck.checked && styleCombo.currentIndex !== 2
        }

        SpinBox {
            id: roundnessSpin
            Kirigami.FormData.label: i18n("Roundness (×10, 2.0..10.0):")
            from: 20; to: 100; stepSize: 1
            visible: !hideFrameCheck.checked && styleCombo.currentIndex !== 2
        }
    }

    Kirigami.FormLayout {
        id: glassSection
        Layout.fillWidth: true
        visible: styleCombo.currentIndex === 0 || styleCombo.currentIndex === 4 || styleCombo.currentIndex === 6

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Glass effect")
        }

        SpinBox {
            id: thicknessSpin
            Kirigami.FormData.label: i18n("Refraction thickness (px):")
            from: 1; to: 80; stepSize: 1
        }

        SpinBox {
            id: iorSpin
            Kirigami.FormData.label: i18n("Index of refraction (×100):")
            from: 100; to: 400; stepSize: 5
        }

        SpinBox {
            id: scaleSpin
            Kirigami.FormData.label: i18n("Refraction strength:")
            from: 0; to: 300; stepSize: 5
        }

        SpinBox {
            id: tintSpin
            Kirigami.FormData.label: i18n("Tint alpha (%):")
            from: 0; to: 100; stepSize: 1
        }

        SpinBox {
            id: chromaSpin
            Kirigami.FormData.label: i18n("Chromatic aberration (%):")
            from: 0; to: 100; stepSize: 1
        }

        SpinBox {
            id: specStrengthSpin
            Kirigami.FormData.label: i18n("Specular strength (%):")
            from: 0; to: 100; stepSize: 5
        }

        SpinBox {
            id: blurRadiusSpin
            Kirigami.FormData.label: i18n("Blur radius (px):")
            from: 0; to: 100; stepSize: 1
        }

        CheckBox {
            id: realtimeCheck
            Kirigami.FormData.label: i18n("Realtime refraction:")
            text: i18n("Recapture every frame (enable for video wallpapers)")
        }
    }
}
