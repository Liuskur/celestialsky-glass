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
    readonly property int gap: 8
    readonly property int lineH: 2
    readonly property int lineGap: 2
    readonly property int gripRows: 3
    readonly property int gripH: gripRows * lineH + (gripRows - 1) * lineGap
    readonly property int edge: 4
    readonly property color barColor: options.titleBarColor
    readonly property color textColor: options.fontColor
    readonly property color frameColor: options.borderColor
    readonly property color dotColor: Kirigami.Theme.tooltipTextColor

    property real marginLeftPct: 0
    property real marginRightPct: 0
    property real marginTopPct: 0
    property real marginBottomPct: 0

    function readConfig() {
        root.marginLeftPct = decoration.readConfig("marginLeftPct", 0)
        root.marginRightPct = decoration.readConfig("marginRightPct", 0)
        root.marginTopPct = decoration.readConfig("marginTopPct", 0)
        root.marginBottomPct = decoration.readConfig("marginBottomPct", 0)
    }

    Component.onCompleted: {
        borders.left = root.edge
        borders.right = root.edge
        borders.bottom = 6
        borders.top = root.barH
        maximizedBorders.left = 0
        maximizedBorders.right = 0
        maximizedBorders.bottom = 0
        maximizedBorders.top = root.barH
        padding.left = 0
        padding.right = 0
        padding.top = 0
        padding.bottom = 0
        readConfig()
    }

    Connections {
        target: decoration
        function onConfigChanged() { root.readConfig() }
    }
    Rectangle {
        anchors.fill: parent
        color: root.barColor
        border.width: decoration.client.maximized ? 0 : 1
        border.color: root.frameColor
    }

    Item {
        id: titleRow
        clip: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.barH
        anchors.leftMargin: (decoration.client.maximized ? 0 : root.edge) + parent.width * root.marginLeftPct / 100
        anchors.rightMargin: (decoration.client.maximized ? 0 : root.edge) + parent.width * root.marginRightPct / 100
        anchors.topMargin: height * root.marginTopPct / 100
        anchors.bottomMargin: 0

        ButtonGroup {
            id: leftButtonGroup
            spacing: 1
            explicitSpacer: 0
            height: titleRow.height
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
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }

        Item {
            id: mid
            clip: true
            anchors.left: leftButtonGroup.right
            anchors.right: rightButtonGroup.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: root.gap
            anchors.rightMargin: root.gap

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
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, Math.max(0, parent.width - 24))
            }

            Item {
                id: grip
                clip: true
                visible: width > 4
                anchors.left: caption.right
                anchors.right: parent.right
                anchors.leftMargin: root.gap
                anchors.verticalCenter: parent.verticalCenter
                height: Math.max(0, root.gripH - parent.height * root.marginBottomPct / 50)

                Canvas {
                    id: stipple
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        var w = width
                        var h = height
                        ctx.clearRect(0, 0, w, h)
                        var t = root.textColor
                        var step = 4
                        var a = decoration.client.active ? 0.42 : 0.22
                        ctx.fillStyle = Qt.rgba(t.r, t.g, t.b, a)
                        var y
                        var x
                        for (y = 1; y < h; y += step) {
                            for (x = 1; x < w; x += step) {
                                ctx.beginPath()
                                ctx.arc(x, y, 1.05, 0, 6.28318530718)
                                ctx.fill()
                            }
                        }
                    }
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                    Connections {
                        target: root
                        function onTextColorChanged() { stipple.requestPaint() }
                    }
                    Connections {
                        target: decoration.client
                        function onActiveChanged() { stipple.requestPaint() }
                    }
                }
            }
        }

        ButtonGroup {
            id: rightButtonGroup
            spacing: 1
            explicitSpacer: 0
            height: titleRow.height
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
            anchors.top: parent.top
            anchors.bottom: parent.bottom
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
