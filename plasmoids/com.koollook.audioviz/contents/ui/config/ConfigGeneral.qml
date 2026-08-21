// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property alias cfg_sourceMode: sourceCombo.currentIndex
    property alias cfg_barCount: barsSpin.value
    property alias cfg_sensitivity: sensSpin.value
    property alias cfg_innerRadiusPct: innerSpin.value

    ComboBox {
        id: sourceCombo
        Kirigami.FormData.label: i18n("Signal:")
        model: [i18n("Microphone"), i18n("Playback (speakers)")]
    }
    SpinBox {
        id: barsSpin
        Kirigami.FormData.label: i18n("Bars:")
        from: 16; to: 96; stepSize: 4
    }
    SpinBox {
        id: sensSpin
        Kirigami.FormData.label: i18n("Sensitivity:")
        from: 5; to: 100; stepSize: 5
    }
    SpinBox {
        id: innerSpin
        Kirigami.FormData.label: i18n("Inner radius (%):")
        from: 10; to: 70; stepSize: 5
    }
    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.7
        text: i18n("Plasma 6 only. Playback uses the default sink monitor (PipeWire/Pulse). Microphone uses the default source.")
    }
}
