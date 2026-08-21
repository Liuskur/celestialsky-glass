import QtQuick
import org.kde.kirigami as Kirigami

QtObject {
    id: koollookColors
    // styleMode:
    //   0 Glass, 1 Solid, 2 Clear (see-through, no frame),
    //   3 Plasma, 4 Chameleon, 5 Inverse, 6 Koollook
    property int styleMode: 0
    property int appearance: 0

    readonly property bool useSystem: appearance === 2
    readonly property bool systemIsDark: {
        var bg = Kirigami.Theme.backgroundColor
        var luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b
        return luminance < 0.5
    }
    readonly property real desktopLum: {
        var bg = Kirigami.Theme.backgroundColor
        return 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b
    }
    readonly property bool desktopIsDark: desktopLum < 0.5

    readonly property bool isGlass: styleMode === 0
    readonly property bool isSolid: styleMode === 1
    readonly property bool isClear: styleMode === 2
    readonly property bool isPlasma: styleMode === 3
    readonly property bool isChameleon: styleMode === 4
    readonly property bool isInverse: styleMode === 5
    readonly property bool isKoollook: styleMode === 6
    readonly property bool usesBackdropShader: isGlass || isChameleon || isKoollook
    readonly property bool showSpecular: isGlass || isChameleon
    readonly property bool hideChrome: isClear

    readonly property color glassTint: {
        if (isKoollook) return "#00d3b8"
        if (isChameleon) return Kirigami.Theme.highlightColor
        if (isLight) return "#ffffff"
        return "#000000"
    }
    readonly property real  glassTintAlpha: {
        if (isClear) return 0
        if (isKoollook) return 0.18
        if (isChameleon) return 0.28
        return isLight ? 0.60 : 0.32
    }
    readonly property real  glassFallbackOpacity: isClear ? 0 : (isLight ? 0.72 : 0.55)

    readonly property color solidBackground: isLight ? "#ffffff" : "#1A1B1E"
    readonly property color solidForeground: isLight ? "#1A1B1E" : "#ffffff"

    readonly property color accentRed: isLight ? "#D70015" : "#FF3B30"
    readonly property color koollookAccent: "#00d3b8"
    readonly property color koollookGold: "#e7bf7e"

    property var foregroundDarkOverride: null

    readonly property bool effectiveLight: foregroundDarkOverride !== null
        ? !foregroundDarkOverride
        : isLight

    readonly property bool useLightGlyphs: {
        if (isInverse || isClear) return desktopIsDark
        if (isPlasma) return systemIsDark
        if (isKoollook || isGlass || isChameleon) return true
        return !effectiveLight
    }

    readonly property color foreground: {
        if (isInverse || isClear)
            return desktopIsDark ? "#ffffff" : "#141414"
        if (isPlasma)
            return Kirigami.Theme.textColor
        if (isKoollook)
            return koollookGold
        if (isGlass || isChameleon)
            return "#ffffff"
        return effectiveLight ? "#1A1B1E" : "#ffffff"
    }

    readonly property color todayAccent: {
        if (isKoollook) return koollookAccent
        if (isInverse || isClear) return foreground
        return isGlass ? "#ffffff" : accentRed
    }

    readonly property bool punchOutText: isGlass && !isClear
        ? !foregroundDarkOverride
        : isLight

    // Foreground used by widget content. Glass stays monochromatic white
    // so the translucent shader keeps its existing look regardless of
    // appearance; Solid follows light/dark inversion.
    readonly property color foreground: isGlass ? "#ffffff" : (effectiveLight ? "#1A1B1E" : "#ffffff")

    // Today/highlight accent: white in Glass (monochrome) and red in Solid.
    readonly property color todayAccent: isGlass ? "#ffffff" : accentRed

    // Badge punch-out: glass uses destination-out compositing, solid uses normal text.
    readonly property bool punchOutText: isGlass

    // Card backgrounds — white on dark modes, black on light solid mode.
    readonly property color cardBackground:        isLight ? "#000000" : "#ffffff"
    readonly property real  cardBackgroundOpacity: isLight ? 0.08 : 0.10
    readonly property real  cardHoverOpacity:      isLight ? 0.14 : 0.17
    readonly property real  cardPressOpacity:      isLight ? 0.20 : 0.22

    // Timer action colors — solid-filled in glass, tinted in solid.
    readonly property color countdownText:  isGlass ? "#ffffff" : "#FF8B00"
    readonly property color actionGreen:    "#00A832"
    readonly property color actionOrange:   "#FF8E00"
    readonly property color buttonIcon:     isGlass ? "#ffffff" : solidForeground
    readonly property color cancelButtonBg: isGlass
        ? Qt.rgba(1, 1, 1, 0.25)
        : Qt.rgba(solidForeground.r, solidForeground.g, solidForeground.b, 0.12)
    readonly property color actionGreenBg:  isGlass ? "#00A832" : Qt.rgba(0, 0.659, 0.196, 0.18)
    readonly property color actionOrangeBg: isGlass ? "#FF8E00" : Qt.rgba(1, 0.557, 0, 0.18)

    // ── Weather tokens ────────────────────────────────────────────────
    property string weatherGradientCategory: "clear"

    readonly property color weatherGradientTop: {
        if (isGlass || isClear || isChameleon || isKoollook || isInverse || isPlasma)
            return "transparent"
        var cat = weatherGradientCategory
        if (cat === "clear")       return "#5188BD"
        if (cat === "cloudy")      return "#8E9EAF"
        if (cat === "rain")        return "#607B8A"
        if (cat === "storm")       return "#3A3A4A"
        if (cat === "snow")        return "#B0C4DE"
        if (cat === "fog")         return "#9CA3AF"
        if (cat === "nightclear")  return "#1A1A3E"
        if (cat === "nightcloudy") return "#2C3040"
        return "#5188BD"
    }

    readonly property color weatherGradientBottom: weatherGradientTop

    readonly property color musicSecondary: useLightGlyphs
        ? Qt.rgba(1, 1, 1, 0.55)
        : Qt.rgba(0.102, 0.106, 0.118, 0.55)

    readonly property color weatherForeground: foreground
    readonly property string weatherIconSet: useLightGlyphs ? "mono-light" : "mono-dark"
    readonly property color weatherSeparator: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.18)
    readonly property color weatherRangeBarBg: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.12)
    readonly property color weatherRangeBarFill: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.55)
}
}
