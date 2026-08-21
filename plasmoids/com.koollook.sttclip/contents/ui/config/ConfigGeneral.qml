// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root
    property alias cfg_deleteClipPhrase: deleteField.text
    property alias cfg_sendClipPhrase: sendField.text

    TextField {
        id: deleteField
        Kirigami.FormData.label: i18n("Clear buffer:")
        placeholderText: i18n("delete clip")
    }
    TextField {
        id: sendField
        Kirigami.FormData.label: i18n("Send buffer:")
        placeholderText: i18n("send clip")
    }
    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.7
        text: i18n("Spoken word-pairs. Dictation stays in the widget until you send. Phrases are stored in ~/.config/koollook/stt.conf for the STT helper.")
    }
}
