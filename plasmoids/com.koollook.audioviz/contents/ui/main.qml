// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import "org/koollook/glass"

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    switchWidth: Kirigami.Units.gridUnit * 8
    switchHeight: Kirigami.Units.gridUnit * 8

    MacOSColors {
        id: colors
        styleMode: Plasmoid.configuration.styleMode
        appearance: Plasmoid.configuration.appearance
    }

    property var bars: []

    readonly property string vizScript: {
        var u = Qt.resolvedUrl("../code/viz.sh").toString()
        return u.replace(/^file:\/\//, "")
    }

    readonly property string vizCmd: {
        var mode = Plasmoid.configuration.sourceMode === 0 ? "mic" : "output"
        return "bash " + vizScript
            + " --mode " + mode
            + " --bars " + Plasmoid.configuration.barCount
            + " --sensitivity " + Plasmoid.configuration.sensitivity
    }

    Plasma5Support.DataSource {
        id: viz
        engine: "executable"
        connectedSources: [root.vizCmd]
        onNewData: function(source, data) {
            var line = (data["stdout"] || "").trim().split("\n").pop()
            if (!line.length)
                return
            var parts = line.split(" ")
            var out = []
            for (var i = 0; i < parts.length; i++) {
                var v = parseFloat(parts[i])
                if (!isNaN(v))
                    out.push(Math.max(0, Math.min(1, v)))
            }
            if (out.length)
                root.bars = out
        }
    }

    Connections {
        target: Plasmoid.configuration
        function onSourceModeChanged() { viz.connectedSources = [root.vizCmd] }
        function onBarCountChanged() { viz.connectedSources = [root.vizCmd] }
        function onSensitivityChanged() { viz.connectedSources = [root.vizCmd] }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 12
        Layout.preferredHeight: Kirigami.Units.gridUnit * 12
        Layout.minimumWidth: Kirigami.Units.gridUnit * 6
        Layout.minimumHeight: Kirigami.Units.gridUnit * 6

        LiquidGlass {
            anchors.fill: parent
            radius: Plasmoid.configuration.cornerRadius
            roundness: Plasmoid.configuration.roundnessX10 / 10
            refractThickness: Plasmoid.configuration.refractThickness
            refractIOR: Plasmoid.configuration.refractIORx100 / 100
            refractScale: Plasmoid.configuration.refractScale
            tint: colors.glassTint
            tintAlpha: Plasmoid.configuration.tintAlphaPct / 100
            chromaStrength: Plasmoid.configuration.chromaStrengthPct / 100
            specStrength: Plasmoid.configuration.specStrengthPct / 100
            blurRadius: Plasmoid.configuration.blurRadiusPx
            realtimeRefraction: Plasmoid.configuration.realtimeRefraction
            fallbackOpacity: colors.glassFallbackOpacity
            solidMode: colors.isSolid
            solidColor: colors.solidBackground
            solidColorBottom: "transparent"
        }

        Canvas {
            id: wave
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var n = root.bars.length
                if (!n)
                    return
                var cx = width / 2
                var cy = height / 2
                var maxR = Math.min(cx, cy) * 0.92
                var inner = maxR * (Plasmoid.configuration.innerRadiusPct / 100)
                var bw = Math.max(2, (2 * Math.PI * inner) / n * 0.55)
                var col = colors.foreground
                ctx.fillStyle = Qt.rgba(col.r, col.g, col.b, 0.92)
                ctx.strokeStyle = Qt.rgba(col.r, col.g, col.b, 0.25)
                ctx.beginPath()
                ctx.arc(cx, cy, inner * 0.85, 0, Math.PI * 2)
                ctx.stroke()
                for (var i = 0; i < n; i++) {
                    var a = (i / n) * Math.PI * 2 - Math.PI / 2
                    var h = inner + root.bars[i] * (maxR - inner)
                    var x0 = cx + Math.cos(a) * inner
                    var y0 = cy + Math.sin(a) * inner
                    var x1 = cx + Math.cos(a) * h
                    var y1 = cy + Math.sin(a) * h
                    ctx.lineWidth = bw
                    ctx.lineCap = "round"
                    ctx.beginPath()
                    ctx.moveTo(x0, y0)
                    ctx.lineTo(x1, y1)
                    ctx.strokeStyle = Qt.rgba(col.r, col.g, col.b, 0.9)
                    ctx.stroke()
                }
            }
        }

        Timer {
            interval: 33
            running: true
            repeat: true
            onTriggered: wave.requestPaint()
        }
    }
}
