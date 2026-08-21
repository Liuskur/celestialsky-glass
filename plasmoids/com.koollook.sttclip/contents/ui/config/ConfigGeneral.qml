// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing

    property string cfg_commandsJson
    property string cfg_deleteClipPhrase
    property string cfg_sendClipPhrase

    readonly property string defaultJson: '{"hard":[{"id":"clear-clip","name":"Delete clip","match":"delete clip","builtin":"clear-clip"},{"id":"send-clip","name":"Send clip","match":"send clip","builtin":"send-clip"}],"custom":[]}'

    ListModel { id: customModel }

    function parseCfg() {
        var raw = cfg_commandsJson && cfg_commandsJson.length ? cfg_commandsJson : defaultJson
        try { return JSON.parse(raw) } catch (e) { return JSON.parse(defaultJson) }
    }

    function dump() {
        var hard = [
            { id: "clear-clip", name: "Delete clip", match: clearMatch.text, builtin: "clear-clip" },
            { id: "send-clip", name: "Send clip", match: sendMatch.text, builtin: "send-clip" }
        ]
        var custom = []
        for (var i = 0; i < customModel.count; i++) {
            var r = customModel.get(i)
            custom.push({ id: r.id, name: r.name, match: r.match, command: r.command })
        }
        cfg_commandsJson = JSON.stringify({ hard: hard, custom: custom })
        cfg_deleteClipPhrase = clearMatch.text
        cfg_sendClipPhrase = sendMatch.text
    }

    function load() {
        var o = parseCfg()
        var hard = o.hard || []
        for (var i = 0; i < hard.length; i++) {
            if (hard[i].builtin === "clear-clip") clearMatch.text = hard[i].match || "delete clip"
            if (hard[i].builtin === "send-clip") sendMatch.text = hard[i].match || "send clip"
        }
        customModel.clear()
        var c = o.custom || []
        for (var j = 0; j < c.length; j++) {
            customModel.append({
                id: c[j].id || ("c" + j),
                name: c[j].name || "",
                match: c[j].match || "",
                command: c[j].command || ""
            })
        }
    }

    Component.onCompleted: load()

    Kirigami.FormLayout {
        Layout.fillWidth: true
        Label {
            text: i18n("Hard commands (clip)")
            font.bold: true
            Kirigami.FormData.isSection: true
        }
        TextField {
            id: clearMatch
            Kirigami.FormData.label: i18n("Delete clip, say:")
            onEditingFinished: root.dump()
        }
        TextField {
            id: sendMatch
            Kirigami.FormData.label: i18n("Send clip, say:")
            onEditingFinished: root.dump()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Label {
            text: i18n("Custom commands")
            font.bold: true
            Layout.fillWidth: true
        }
        Button {
            icon.name: "list-add"
            text: i18n("Add")
            onClicked: addDialog.open()
        }
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        opacity: 0.7
        text: i18n("Like KDE Connect Run Command: when STT hears the match phrase, Plasma 6 runs the command locally.")
    }

    Repeater {
        model: customModel
        delegate: RowLayout {
            Layout.fillWidth: true
            required property int index
            required property string name
            required property string match
            required property string command
            Label {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: (name || match) + "  ·  “" + match + "”"
            }
            Button {
                icon.name: "edit-entry"
                display: AbstractButton.IconOnly
                onClicked: {
                    editDialog.index = index
                    editName.text = name
                    editMatch.text = match
                    editCmd.text = command
                    editDialog.open()
                }
            }
            Button {
                icon.name: "edit-delete"
                display: AbstractButton.IconOnly
                onClicked: {
                    customModel.remove(index)
                    root.dump()
                }
            }
        }
    }

    Dialog {
        id: addDialog
        title: i18n("Add command")
        modal: true
        standardButtons: Dialog.Cancel | Dialog.Ok
        width: Kirigami.Units.gridUnit * 22
        onAccepted: {
            if (!addMatch.text.length || !addCmd.text.length)
                return
            customModel.append({
                id: "c" + Date.now(),
                name: addName.text,
                match: addMatch.text,
                command: addCmd.text
            })
            addName.text = ""; addMatch.text = ""; addCmd.text = ""
            root.dump()
        }
        Kirigami.FormLayout {
            TextField {
                id: addName
                Kirigami.FormData.label: i18n("Name:")
            }
            TextField {
                id: addMatch
                Kirigami.FormData.label: i18n("Say (match):")
                placeholderText: i18n("lock screen")
            }
            TextField {
                id: addCmd
                Kirigami.FormData.label: i18n("Command:")
                placeholderText: i18n("loginctl lock-session")
            }
            ComboBox {
                Kirigami.FormData.label: i18n("Samples:")
                model: [
                    { name: i18n("Lock screen"), match: "lock screen", command: "loginctl lock-session" },
                    { name: i18n("Overview"), match: "overview", command: "qdbus6 org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut Overview" },
                    { name: i18n("Mute"), match: "mute audio", command: "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" }
                ]
                textRole: "name"
                currentIndex: -1
                displayText: currentIndex < 0 ? i18n("Choose…") : currentText
                onActivated: {
                    addName.text = model[currentIndex].name
                    addMatch.text = model[currentIndex].match
                    addCmd.text = model[currentIndex].command
                }
            }
        }
    }

    Dialog {
        id: editDialog
        title: i18n("Edit command")
        modal: true
        property int index: 0
        standardButtons: Dialog.Cancel | Dialog.Ok
        width: Kirigami.Units.gridUnit * 22
        onAccepted: {
            customModel.set(index, {
                id: customModel.get(index).id,
                name: editName.text,
                match: editMatch.text,
                command: editCmd.text
            })
            root.dump()
        }
        Kirigami.FormLayout {
            TextField { id: editName; Kirigami.FormData.label: i18n("Name:") }
            TextField { id: editMatch; Kirigami.FormData.label: i18n("Say (match):") }
            TextField { id: editCmd; Kirigami.FormData.label: i18n("Command:") }
        }
    }
}
