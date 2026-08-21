// SPDX-License-Identifier: MIT
import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

// Shared frame: one place for styleMode (glass/solid/clear/plasma/chameleon/inverse/koollook).
Item {
    id: frame
    anchors.fill: parent

    readonly property int styleMode: Plasmoid.configuration.styleMode
    readonly property bool hideFrame: Plasmoid.configuration.hideFrame === true
        || Plasmoid.configuration.hideFrame === 1

    KoollookColors {
        id: pal
        styleMode: frame.styleMode
        appearance: Plasmoid.configuration.appearance
    }
    readonly property alias colors: pal

    LiquidGlass {
        id: glass
        anchors.fill: parent
        visible: pal.usesBackdropShader && !pal.isClear
        radius: frame.hideFrame ? 0 : Plasmoid.configuration.cornerRadius
        roundness: Plasmoid.configuration.roundnessX10 / 10
        refractThickness: (pal.isClear || frame.hideFrame) ? 0 : Plasmoid.configuration.refractThickness
        refractIOR: Plasmoid.configuration.refractIORx100 / 100
        refractScale: (pal.isClear || frame.hideFrame) ? 0 : Plasmoid.configuration.refractScale
        tint: pal.glassTint
        tintAlpha: pal.isClear ? 0 : (pal.isGlass ? Plasmoid.configuration.tintAlphaPct / 100 : pal.glassTintAlpha)
        chromaStrength: pal.isClear || frame.hideFrame ? 0 : Plasmoid.configuration.chromaStrengthPct / 100
        specStrength: (pal.showSpecular && !frame.hideFrame) ? Plasmoid.configuration.specStrengthPct / 100 : 0
        specEnabled: pal.showSpecular && !frame.hideFrame
        blurRadius: pal.isClear ? 0 : Plasmoid.configuration.blurRadiusPx
        realtimeRefraction: Plasmoid.configuration.realtimeRefraction
        fallbackOpacity: pal.isClear || frame.hideFrame ? 0 : pal.glassFallbackOpacity
        solidMode: pal.isSolid
        solidColor: pal.solidBackground
        solidColorBottom: "transparent"
    }

    Rectangle {
        anchors.fill: parent
        visible: pal.isPlasma && !pal.isClear
        color: Kirigami.Theme.backgroundColor
        opacity: frame.hideFrame ? 0 : 0.82
        radius: frame.hideFrame ? 0 : Math.min(width, height) * 0.08
        border.width: frame.hideFrame || pal.isClear ? 0 : 1
        border.color: Kirigami.Theme.highlightColor
    }
}
