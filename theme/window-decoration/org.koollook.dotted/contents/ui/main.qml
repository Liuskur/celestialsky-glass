import QtQuick
import org.kde.kwin.decoration
import org.kde.kirigami as Kirigami

Decoration {
    id: root

    DecorationOptions {
        id: options
        deco: decoration
    }

    readonly property int barH: 28
    readonly property int gap: 10
    readonly property int dottedCell: 7
    readonly property int dottedRows: 3
    readonly property int dottedH: dottedCell * dottedRows
    readonly property color barColor: "#1d1d27"
    readonly property color textColor: decoration.client.active ? "#e7bf7e" : "#666a73"

    Component.onCompleted: {
        borders.left = 4
        borders.right = 4
        borders.bottom = 6
        borders.top = barH
        maximizedBorders.left = 0
        maximizedBorders.right = 0
        maximizedBorders.bottom = 0
        maximizedBorders.top = barH
        padding.left = 0
        padding.right = 0
        padding.top = 0
        padding.bottom = 0
    }

    Rectangle {
        anchors.fill: parent
        color: root.barColor
        border.width: decoration.client.maximized ? 0 : 1
        border.color: "#000000"
    }

    Item {
        id: titleRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.barH
        anchors.leftMargin: decoration.client.maximized ? 0 : 4
        anchors.rightMargin: decoration.client.maximized ? 0 : 4

        ButtonGroup {
            id: leftButtonGroup
            spacing: 1
            explicitSpacer: 10
            buttons: options.titleButtonsLeft
            menuButton: menuComp
            appMenuButton: menuComp
            minimizeButton: minComp
            maximizeButton: maxComp
            closeButton: closeComp
            keepAboveButton: aboveComp
            keepBelowButton: belowComp
            allDesktopsButton: allDeskComp
            helpButton: minComp
            shadeButton: minComp
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: caption
            textFormat: Text.PlainText
            text: decoration.client.caption
            color: root.textColor
            font: options.titleFont
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            height: parent.height
            x: leftButtonGroup.x + leftButtonGroup.width + 8
            width: Math.min(implicitWidth, Math.max(0, rightButtonGroup.x - root.gap - x))
        }

        Item {
            id: grip
            clip: true
            visible: width > 6
            height: parent.height
            x: caption.x + caption.width + root.gap
            width: Math.max(0, rightButtonGroup.x - root.gap - x)
            Image {
                width: Math.max(parent.width, 7)
                height: Math.max(parent.height, 7)
                fillMode: Image.Tile
                source: Qt.resolvedUrl("dots.svg")
                horizontalAlignment: Image.AlignLeft
                verticalAlignment: Image.AlignTop
            }
        }

        ButtonGroup {
            id: rightButtonGroup
            spacing: 1
            explicitSpacer: 10
            buttons: options.titleButtonsRight
            menuButton: menuComp
            appMenuButton: menuComp
            minimizeButton: minComp
            maximizeButton: maxComp
            closeButton: closeComp
            keepAboveButton: aboveComp
            keepBelowButton: belowComp
            allDesktopsButton: allDeskComp
            helpButton: minComp
            shadeButton: minComp
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }

        Component.onCompleted: decoration.installTitleItem(titleRow)
    }

    Component {
        id: closeComp
        KoollookButton {
            svgFile: "close.svg"
            btnWidth: 44
            buttonType: DecorationOptions.DecorationButtonClose
        }
    }
    Component {
        id: minComp
        KoollookButton {
            svgFile: "minimize.svg"
            btnWidth: 44
            buttonType: DecorationOptions.DecorationButtonMinimize
        }
    }
    Component {
        id: maxComp
        KoollookButton {
            svgFile: decoration.client.maximized ? "restore.svg" : "maximize.svg"
            btnWidth: 44
            buttonType: DecorationOptions.DecorationButtonMaximizeRestore
        }
    }
    Component {
        id: aboveComp
        KoollookButton {
            svgFile: "keepabove.svg"
            btnWidth: 43
            buttonType: DecorationOptions.DecorationButtonKeepAbove
        }
    }
    Component {
        id: belowComp
        KoollookButton {
            svgFile: "keepbelow.svg"
            btnWidth: 43
            buttonType: DecorationOptions.DecorationButtonKeepBelow
        }
    }
    Component {
        id: allDeskComp
        KoollookButton {
            svgFile: "alldesktops.svg"
            btnWidth: 44
            buttonType: DecorationOptions.DecorationButtonOnAllDesktops
        }
    }
    Component {
        id: menuComp
        DecorationButton {
            buttonType: DecorationOptions.DecorationButtonMenu
            width: 28
            height: 28
            Kirigami.Icon {
                anchors.fill: parent
                anchors.margins: 4
                source: decoration.client.icon
            }
        }
    }
}
