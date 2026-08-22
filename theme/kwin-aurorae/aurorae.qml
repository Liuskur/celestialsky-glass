/*
    SPDX-FileCopyrightText: 2012 Martin Gräßlin <mgraesslin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import org.kde.kwin.decoration
import org.kde.ksvg 1.0 as KSvg
import org.kde.kirigami as Kirigami

Decoration {
    id: root
    property bool animate: false
    property alias decorationMask: maskItem.mask
    property alias supportsMask: backgroundSvg.supportsMask
    Component.onCompleted: {
        borders.left   = Qt.binding(function() { return Math.max(0, auroraeTheme.borderLeft);});
        borders.right  = Qt.binding(function() { return Math.max(0, auroraeTheme.borderRight);});
        borders.top    = Qt.binding(function() { return Math.max(0, auroraeTheme.borderTop);});
        borders.bottom = Qt.binding(function() { return Math.max(0, auroraeTheme.borderBottom);});
        maximizedBorders.left   = Qt.binding(function() { return Math.max(0, auroraeTheme.borderLeftMaximized);});
        maximizedBorders.right  = Qt.binding(function() { return Math.max(0, auroraeTheme.borderRightMaximized);});
        maximizedBorders.bottom = Qt.binding(function() { return Math.max(0, auroraeTheme.borderBottomMaximized);});
        maximizedBorders.top    = Qt.binding(function() { return Math.max(0, auroraeTheme.borderTopMaximized);});
        padding.left   = auroraeTheme.paddingLeft;
        padding.right  = auroraeTheme.paddingRight;
        padding.bottom = auroraeTheme.paddingBottom;
        padding.top    = auroraeTheme.paddingTop;
        root.animate = true;
    }
    DecorationOptions {
        id: options
        deco: decoration
    }
    readonly property bool koollookTheme: String(auroraeTheme.decorationPath || "").indexOf("Koollook") >= 0
    readonly property bool dottedSpacer: {
        if (!root.koollookTheme)
            return false
        function hasSp(list) {
            if (!list)
                return false
            var i
            for (i = 0; i < list.length; i++) {
                if (list[i] === DecorationOptions.DecorationButtonExplicitSpacer)
                    return true
            }
            return false
        }
        return hasSp(options.titleButtonsLeft) || hasSp(options.titleButtonsRight)
    }
    readonly property string dottedTile: {
        var p = String(auroraeTheme.decorationPath || "")
        var i = p.lastIndexOf("/")
        return (i >= 0 ? p.substring(0, i) : "") + "/dots.svg"
    }
    readonly property real captionTextW: caption ? Math.min(caption.contentWidth, caption.width) : 0
    readonly property real captionTextX: {
        if (!caption)
            return 0
        if (caption.horizontalAlignment === Text.AlignRight)
            return caption.x + caption.width - captionTextW
        if (caption.horizontalAlignment === Text.AlignHCenter)
            return caption.x + (caption.width - captionTextW) / 2
        return caption.x
    readonly property int dottedCell: 4
    readonly property int dottedRows: 3
    readonly property int dottedH: 10
    readonly property color dottedInk: Kirigami.Theme.tooltipTextColor
    readonly property real barTop: decoration.client.maximized ? auroraeTheme.titleEdgeTopMaximized : (auroraeTheme.titleEdgeTop + root.padding.top)
    readonly property real barH: Math.max(auroraeTheme.titleHeight, auroraeTheme.buttonHeight * auroraeTheme.buttonSizeFactor)
    readonly property bool dottedBar: String(auroraeTheme.decorationPath || "").indexOf("KoollookDotted") >= 0
    component Stipple: Canvas {
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var t = root.dottedInk
            var a = decoration.client.active ? 0.55 : 0.28
            ctx.fillStyle = Qt.rgba(t.r, t.g, t.b, a)
            var step = 4
            var y
            var x
            for (y = 1; y < height; y += step) {
                for (x = 1; x < width; x += step) {
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
            function onDottedInkChanged() { requestPaint() }
        }
        Connections {
            target: decoration.client
            function onActiveChanged() { requestPaint() }
        }
    }



    Item {
        id: titleRect
        x: decoration.client.maximized ? maximizedBorders.left : borders.left
        y: decoration.client.maximized ? 0 : root.borders.bottom
        width: decoration.client.width//parent.width - x - (decoration.client.maximized ? maximizedBorders.right : borders.right)
        height: decoration.client.maximized ? maximizedBorders.top : borders.top
        Component.onCompleted: {
            decoration.installTitleItem(titleRect);
        }
    }
    Stipple {
        visible: root.dottedBar
        z: 0
        x: decoration.client.maximized ? 0 : root.borders.left
        y: decoration.client.maximized ? 0 : root.padding.top
        width: Math.max(0, root.width - x - (decoration.client.maximized ? 0 : root.borders.right))
        height: root.barH
    }
    KSvg.FrameSvg {
        property bool supportsInactive: hasElementPrefix("decoration-inactive")
        property bool supportsMask: hasElementPrefix("mask")
        property bool supportsMaximized: hasElementPrefix("decoration-maximized")
        property bool supportsMaximizedInactive: hasElementPrefix("decoration-maximized-inactive")
        property bool supportsInnerBorder: hasElementPrefix("innerborder")
        property bool supportsInnerBorderInactive: hasElementPrefix("innerborder-inactive")
        id: backgroundSvg
        imagePath: auroraeTheme.decorationPath
    }
    KSvg.FrameSvgItem {
        id: decorationActive
        property bool shown: (!decoration.client.maximized || !backgroundSvg.supportsMaximized) && (decoration.client.active || !backgroundSvg.supportsInactive)
        anchors.fill: parent
        imagePath: backgroundSvg.imagePath
        prefix: "decoration"
        opacity: shown ? 1 : 0
        enabledBorders: decoration.client.maximized ? KSvg.FrameSvg.NoBorder : KSvg.FrameSvg.TopBorder | KSvg.FrameSvg.BottomBorder | KSvg.FrameSvg.LeftBorder | KSvg.FrameSvg.RightBorder
        Behavior on opacity {
            enabled: root.animate
            NumberAnimation {
                duration: auroraeTheme.animationTime
            }
        }
    }
    KSvg.FrameSvgItem {
        id: decorationInactive
        anchors.fill: parent
        imagePath: backgroundSvg.imagePath
        prefix: "decoration-inactive"
        opacity: (!decoration.client.active && backgroundSvg.supportsInactive) ? 1 : 0
        enabledBorders: decoration.client.maximized ? KSvg.FrameSvg.NoBorder : KSvg.FrameSvg.TopBorder | KSvg.FrameSvg.BottomBorder | KSvg.FrameSvg.LeftBorder | KSvg.FrameSvg.RightBorder
        Behavior on opacity {
            enabled: root.animate
            NumberAnimation {
                duration: auroraeTheme.animationTime
            }
        }
    }
    KSvg.FrameSvgItem {
        id: decorationMaximized
        property bool shown: decoration.client.maximized && backgroundSvg.supportsMaximized && (decoration.client.active || !backgroundSvg.supportsMaximizedInactive)
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 0
            rightMargin: 0
            topMargin: 0
        }
        imagePath: backgroundSvg.imagePath
        prefix: "decoration-maximized"
        height: parent.maximizedBorders.top
        opacity: shown ? 1 : 0
        enabledBorders: KSvg.FrameSvg.NoBorder
        Behavior on opacity {
            enabled: root.animate
            NumberAnimation {
                duration: auroraeTheme.animationTime
            }
        }
    }
    KSvg.FrameSvgItem {
        id: decorationMaximizedInactive
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 0
            rightMargin: 0
            topMargin: 0
        }
        imagePath: backgroundSvg.imagePath
        prefix: "decoration-maximized-inactive"
        height: parent.maximizedBorders.top
        opacity: (!decoration.client.active && decoration.client.maximized && backgroundSvg.supportsMaximizedInactive) ? 1 : 0
        enabledBorders: KSvg.FrameSvg.NoBorder
        Behavior on opacity {
            enabled: root.animate
            NumberAnimation {
                duration: auroraeTheme.animationTime
            }
        }
    }
    AuroraeButtonGroup {
        id: leftButtonGroup
        buttons: options.titleButtonsLeft
        width: childrenRect.width
        animate: root.animate
        anchors {
            left: root.left
            leftMargin: decoration.client.maximized ? auroraeTheme.titleEdgeLeftMaximized : (auroraeTheme.titleEdgeLeft + root.padding.left)
        }
    }
    AuroraeButtonGroup {
        id: rightButtonGroup
        buttons: options.titleButtonsRight
        width: childrenRect.width
        animate: root.animate
        anchors {
            right: root.right
            rightMargin: decoration.client.maximized ? auroraeTheme.titleEdgeRightMaximized : (auroraeTheme.titleEdgeRight + root.padding.right)
        }
    }
    Item {
        id: dottedLeft
        visible: root.dottedSpacer && !root.dottedBar && width > 6
        clip: true
        z: 0
        height: root.dottedH
        y: leftButtonGroup.y + Math.max(0, (leftButtonGroup.height - root.dottedH) / 2)
        x: leftButtonGroup.x + leftButtonGroup.width + 6
        width: Math.max(0, root.captionTextX - 6 - x)
        Stipple { anchors.fill: parent }
    }
    Item {
        id: dottedRight
        visible: root.dottedSpacer && !root.dottedBar && width > 6
        clip: true
        z: 0
        height: root.dottedH
        y: rightButtonGroup.y + Math.max(0, (rightButtonGroup.height - root.dottedH) / 2)
        x: root.captionTextX + root.captionTextW + 6
        width: Math.max(0, rightButtonGroup.x - 6 - x)
        Stipple { anchors.fill: parent }
    }
    Text {
        id: caption
        z: 1
        text: decoration.client.caption
        textFormat: Text.PlainText
        horizontalAlignment: auroraeTheme.horizontalAlignment
        verticalAlignment: auroraeTheme.verticalAlignment
        elide: Text.ElideRight
        height: Math.max(auroraeTheme.titleHeight, auroraeTheme.buttonHeight * auroraeTheme.buttonSizeFactor)
        color: root.koollookTheme ? options.fontColor : (decoration.client.active ? auroraeTheme.activeTextColor : auroraeTheme.inactiveTextColor)
        font: options.titleFont
        renderType: Text.NativeRendering
        anchors {
            left: leftButtonGroup.right
            right: rightButtonGroup.left
            top: root.top
            topMargin: decoration.client.maximized ? auroraeTheme.titleEdgeTopMaximized : (auroraeTheme.titleEdgeTop + root.padding.top)
            leftMargin: auroraeTheme.titleBorderLeft
            rightMargin: auroraeTheme.titleBorderRight
        }
        Behavior on color {
            enabled: root.animate
            ColorAnimation {
                duration: auroraeTheme.animationTime
            }
        }
    }
    KSvg.FrameSvgItem {
        id: innerBorder
        anchors {
            fill: parent
            leftMargin: parent.padding.left + parent.borders.left - margins.left
            rightMargin: parent.padding.right + parent.borders.right - margins.right
            topMargin: parent.padding.top + parent.borders.top - margins.top
            bottomMargin: parent.padding.bottom + parent.borders.bottom - margins.bottom
        }
        visible: parent.borders.left > fixedMargins.left
            && parent.borders.right > fixedMargins.right
            && parent.borders.top > fixedMargins.top
            && parent.borders.bottom > fixedMargins.bottom

        imagePath: backgroundSvg.imagePath
        prefix: "innerborder"
        opacity: (decoration.client.active && !decoration.client.maximized && backgroundSvg.supportsInnerBorder) ? 1 : 0
        Behavior on opacity {
            enabled: root.animate
            NumberAnimation {
                duration: auroraeTheme.animationTime
            }
        }
    }
    KSvg.FrameSvgItem {
        id: innerBorderInactive
        anchors {
            fill: parent
            leftMargin: parent.padding.left + parent.borders.left - margins.left
            rightMargin: parent.padding.right + parent.borders.right - margins.right
            topMargin: parent.padding.top + parent.borders.top - margins.top
            bottomMargin: parent.padding.bottom + parent.borders.bottom - margins.bottom
        }

        visible: parent.borders.left > fixedMargins.left
            && parent.borders.right > fixedMargins.right
            && parent.borders.top > fixedMargins.top
            && parent.borders.bottom > fixedMargins.bottom

        imagePath: backgroundSvg.imagePath
        prefix: "innerborder-inactive"
        opacity: (!decoration.client.active && !decoration.client.maximized && backgroundSvg.supportsInnerBorderInactive) ? 1 : 0
        Behavior on opacity {
            enabled: root.animate
            NumberAnimation {
                duration: auroraeTheme.animationTime
            }
        }
    }
    KSvg.FrameSvgItem {
        id: maskItem
        anchors.fill: parent
        // This makes the mask slightly smaller than the frame. Since the svg will have antialiasing and the mask not,
        // there will be artifacts at the corners, if they go under the svg they're less evident
        anchors.margins: 1
        imagePath: backgroundSvg.imagePath
        opacity: 0
        enabledBorders: KSvg.FrameSvg.TopBorder | KSvg.FrameSvg.BottomBorder | KSvg.FrameSvg.LeftBorder | KSvg.FrameSvg.RightBorder
    }
}
}
