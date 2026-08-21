import QtQuick
import QtQuick.Layouts
import "astronomy.js" as Astronomy
import "org/koollook/glass"
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    // Appearance palette — same KoollookColors axes as calendar / weather
    KoollookColors {
        id: colors
        styleMode: Plasmoid.configuration.styleMode
        appearance: Plasmoid.configuration.appearance
    }

    // ── Location / sky (same lat/lon keys as Weather widget) ──────────
    readonly property real userLat: Plasmoid.configuration.latitude
    readonly property real userLon: Plasmoid.configuration.longitude
    readonly property real planetScale: Plasmoid.configuration.planetScale
    readonly property real bgOpacity: Plasmoid.configuration.bgOpacity

    Connections {
        target: Plasmoid.configuration
        function onLatitudeChanged() { root.refreshSky() }
        function onLongitudeChanged() { root.refreshSky() }
        function onPlanetScaleChanged() { root.refreshSky() }
        function onBgOpacityChanged() {
            if (typeof skyCanvas !== "undefined" && skyCanvas)
                skyCanvas.requestPaint()
        }
    }

    property var iconConfig: ({
        "Sun":     { mode: "image", image: "Sun.png",     size: 30 },
        // Moon ~30% smaller than prior (was 18)
        "Moon":    { mode: "image", size: 13,
                     images: ["Moon0.png","Moon1.png","Moon2.png","Moon3.png",
                              "Moon4.png","Moon5.png","Moon6.png","Moon7.png"] },
        "Mercury": { mode: "image", image: "Mercury.png", size: 7 },
        "Venus":   { mode: "image", image: "Venus.png",   size: 8 },
        "Mars":    { mode: "image", image: "Mars.png",    size: 8 },
        "Jupiter": { mode: "image", size: 11,
                     images: ["Jupiter0.png","Jupiter1.png","Jupiter2.png",
                              "Jupiter3.png","Jupiter4.png"] },
        "Saturn":  { mode: "image", size: 12,
                     images: ["Saturn0.png","Saturn1.png","Saturn2.png",
                              "Saturn3.png","Saturn4.png"] },
        "Uranus":  { mode: "image", image: "Uranus.png",  size: 7 },
        "Neptune": { mode: "image", image: "Neptune.png", size: 7 }
    })

    function iconUrl(name) {
        return Qt.resolvedUrl("icons/" + name)
    }

    property var objects: []
    // Hours from present; driven by glass time scrubber (−72…+72, 1 h steps)
    property int timeOffsetHours: 0
    // Shared by every rise/set tabloid (each card has its own fill area)
    property real tabloidTintAlpha: 0.5
    property color tabloidTint: "#000000"

    function recomputeObjects() {
        try { objects = computeObjects() } catch (e) {
            console.log("computeObjects failed:", e)
            objects = []
        }
    }

    function refreshSky() {
        recomputeObjects()
        // full repaints via Connections (skyCanvas lives inside fullRepresentation)
        skyPaintTick++
    }

    // Bumped whenever sky must redraw (scrub / timer / config)
    property int skyPaintTick: 0

    function setTimeOffsetHours(h) {
        var v = Math.round(Number(h))
        if (v < -72) v = -72
        if (v > 72) v = 72
        if (timeOffsetHours !== v)
            timeOffsetHours = v
        recomputeObjects()
        skyPaintTick++
    }

    function snapTimeToPresent() {
        setTimeOffsetHours(0)
    }

    onTimeOffsetHoursChanged: skyPaintTick++

    fullRepresentation: Item {
        id: full
        Layout.preferredWidth: 500
        Layout.preferredHeight: 340
        Layout.minimumWidth: 280
        Layout.minimumHeight: 220

        // Desktop edit mode (widget rearrange). Outside it, block empty-area drags
        // from moving the applet so the time scrubber stays usable.
        readonly property bool desktopEditMode: {
            try {
                return !!(Plasmoid.containment && Plasmoid.containment.corona
                          && Plasmoid.containment.corona.editMode)
            } catch (e) { return false }
        }

        KoollookFrame {
            id: glass
            anchors.fill: parent
        }

        // Cancel parent applet edit/drag if containment opened handles after a hold.
        function cancelAppletEdit() {
            try {
                var p = full.parent
                var guard = 0
                while (p && guard++ < 12) {
                    if (typeof p.cancelEdit === "function")
                        p.cancelEdit()
                    if (p.editMode === true)
                        p.editMode = false
                    p = p.parent
                }
                if (Plasmoid.containment && Plasmoid.containment.corona
                        && Plasmoid.containment.corona.editMode)
                    Plasmoid.containment.corona.editMode = false
            } catch (e) { /* ignore */ }
        }

        // Absorb presses on empty glass so desktop press-and-hold can't enter
        // applet edit mode (outside corona edit mode). Scrubber sits above this.
        MouseArea {
            anchors.fill: parent
            z: 1
            enabled: !full.desktopEditMode
            preventStealing: true
            hoverEnabled: false
            propagateComposedEvents: false
            onPressed: function(mouse) { mouse.accepted = true }
            onPressAndHold: function(mouse) { mouse.accepted = true }
            onReleased: function(mouse) {
                mouse.accepted = true
                full.cancelAppletEdit()
            }
            onCanceled: full.cancelAppletEdit()
        }

        // Clip content to rounded frame (no layer cache — Canvas must repaint live)
        Item {
            id: content
            anchors.fill: parent
            anchors.margins: 2
            clip: true
            z: 2

            // Full-area canvas: clear pixels so LiquidGlass shows through
            // (including under/around rise-set tabloids — no bottom band).
            Canvas {
                id: skyCanvas
                anchors.fill: parent
                z: 0
                // Ensure paint sees latest offset even if objects ref is stale
                property int tick: root.skyPaintTick
                property int hours: root.timeOffsetHours

                onWidthChanged:  requestPaint()
                onHeightChanged: requestPaint()
                onImageLoaded:   requestPaint()
                onTickChanged:   requestPaint()
                onHoursChanged:  requestPaint()

                Component.onCompleted: {
                    root.recomputeObjects()
                    loadAllImages(skyCanvas)
                    requestPaint()
                }

                Timer {
                    interval: 60000
                    running: true
                    repeat: true
                    onTriggered: root.refreshSky()
                }

                Connections {
                    target: root
                    function onObjectsChanged() { skyCanvas.requestPaint() }
                    function onSkyPaintTickChanged() { skyCanvas.requestPaint() }
                    function onTimeOffsetHoursChanged() { skyCanvas.requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    var W = width
                    var H = height
                    ctx.clearRect(0, 0, W, H)

                    // Optional fill — default 0 = fully transparent glass
                    if (root.bgOpacity > 0.001) {
                        ctx.fillStyle = "rgba(17,24,39," + root.bgOpacity + ")"
                        ctx.beginPath()
                        if (typeof ctx.roundRect === "function")
                            ctx.roundRect(0, 0, W, H, 10)
                        else
                            ctx.rect(0, 0, W, H)
                        ctx.fill()
                    }

                    if (W < 40 || H < 40) return

                    // Horizon sits just above the time scrubber / tabloid strip
                    var stripTop = scrubBar.y
                    if (!(stripTop > 0 && stripTop < H))
                        stripTop = infoPanel.y
                    if (!(stripTop > 0 && stripTop < H))
                        stripTop = H - infoPanel.height - 30

                    var cx = W / 2
                    // Horizon above scrubber/tabloids; peak sized so Sun top edge meets canvas top
                    var arcBottomMargin = 14
                    var hy = stripTop - arcBottomMargin
                    var sidePad = 28
                    // Iterate once so sun radius fits: peak center y = sunSz ⇒ top edge @ y=0
                    var bodyScale = 1
                    var sunSz = 30
                    var R = 48
                    for (var fit = 0; fit < 3; fit++) {
                        R = Math.min(cx - sidePad, Math.max(48, hy - sunSz))
                        R = Math.max(48, R)
                        bodyScale = R / 130
                        sunSz = 30 * bodyScale
                    }
                    // Outer arc peaks at y = hy - R; sun (90°) center sits there → top at ~0
                    var sunPeakY = hy - R

                    ctx.save()
                    // Clip sky drawing to above tabloids (glass continues below)
                    // Allow 1px bleed so sun edge can touch the top border cleanly
                    ctx.beginPath()
                    ctx.rect(0, 0, W, stripTop)
                    ctx.clip()

                    // Horizon line (above tabloid strip by arcBottomMargin)
                    ctx.beginPath()
                    ctx.moveTo(cx - R - 8, hy)
                    ctx.lineTo(cx + R + 8, hy)
                    ctx.strokeStyle = "rgba(255,255,255,0.30)"
                    ctx.lineWidth = 1.5
                    ctx.stroke()

                    ctx.beginPath()
                    ctx.moveTo(cx - R, hy - 7)
                    ctx.lineTo(cx - R, hy + 7)
                    ctx.strokeStyle = "rgba(255,255,255,0.25)"
                    ctx.lineWidth = 1.5
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(cx + R, hy - 7)
                    ctx.lineTo(cx + R, hy + 7)
                    ctx.strokeStyle = "rgba(255,255,255,0.25)"
                    ctx.lineWidth = 1.5
                    ctx.stroke()

                    // Zenith tick at outer-arc peak (sun center at noon)
                    ctx.beginPath()
                    ctx.moveTo(cx, sunPeakY - 6)
                    ctx.lineTo(cx, sunPeakY + 6)
                    ctx.strokeStyle = "rgba(255,255,255,0.22)"
                    ctx.lineWidth = 1
                    ctx.stroke()

                    // Outer sky arc — bottom on horizon; peak under widget top for sun disk
                    ctx.beginPath()
                    ctx.arc(cx, hy, R, Math.PI, 0, false)
                    ctx.strokeStyle = "rgba(255,255,255,0.20)"
                    ctx.lineWidth = 1.5
                    ctx.stroke()

                    // Arc lanes: Sun at max height, planets lower, Moon between them
                    var bodies = root.objects.slice()
                    var maxPlanetAlt = 0
                    for (var j = 0; j < bodies.length; j++) {
                        var bn = bodies[j].name
                        if (bn !== "Sun" && bn !== "Moon")
                            maxPlanetAlt = Math.max(maxPlanetAlt, bodies[j].maxAlt)
                    }
                    if (maxPlanetAlt < 5)
                        maxPlanetAlt = 5
                    var sunDisplayAlt = 90
                    var moonDisplayAlt = (sunDisplayAlt + maxPlanetAlt) * 0.5

                    // Precompute screen positions, then draw large bodies first so
                    // smaller ones (e.g. Jupiter next to Moon/Sun) are not clipped under them.
                    var drawn = []
                    for (var i = 0; i < bodies.length; i++) {
                        var o = bodies[i]
                        var pathAlt = o.maxAlt
                        if (o.name === "Sun")
                            pathAlt = sunDisplayAlt
                        else if (o.name === "Moon")
                            pathAlt = moonDisplayAlt
                        var altRad = pathAlt * Math.PI / 180
                        var acy = hy + R * Math.cos(altRad)

                        ctx.beginPath()
                        ctx.arc(cx, acy, R, Math.PI, 0, false)
                        ctx.strokeStyle = "rgba(200,215,235,0.13)"
                        ctx.lineWidth = 1
                        ctx.stroke()

                        // Night cycle: body fully off the sky (no horizon stick / ghost dots)
                        if (!o.aboveHorizon || o.frac < 0 || o.frac > 1)
                            continue

                        var riseAngle  = Math.PI / 2 + altRad
                        var setAngle   = Math.PI / 2 - altRad
                        var renderFrac = Math.max(0, Math.min(1, o.frac))
                        var angle = riseAngle + (setAngle - riseAngle) * renderFrac
                        var ox = cx + R * Math.cos(angle)
                        var oy = acy - R * Math.sin(angle)
                        var sz = o.size * bodyScale
                        // Lateral pad only; Sun may sit with top edge on canvas top (y≈0)
                        var edgePad = sz + 2
                        if (ox < edgePad) ox = edgePad
                        if (ox > W - edgePad) ox = W - edgePad
                        if (o.name !== "Sun") {
                            if (oy < edgePad) oy = edgePad
                        } else {
                            // Keep exact peak geometry: center at sunPeakY when high
                            if (oy < sunSz) oy = sunSz
                        }
                        if (oy > hy - 2) oy = hy - 2
                        drawn.push({
                            o: o, ox: ox, oy: oy, sz: sz,
                            above: true, pathAlt: pathAlt
                        })
                    }

                    drawn.sort(function(a, b) { return b.sz - a.sz })

                    for (var k = 0; k < drawn.length; k++) {
                        var d = drawn[k]
                        var o2 = d.o
                        var ox2 = d.ox
                        var oy2 = d.oy
                        var sz2 = d.sz

                        if (o2.mode === "image") {
                            var src = (o2.images && o2.images.length > 0)
                                ? iconUrl(o2.images[o2.imageIndex || 0])
                                : iconUrl(o2.image)
                            // Draw full PNG with its own alpha — no circular clip
                            function paintBody(alpha) {
                                ctx.save()
                                if (alpha < 1)
                                    ctx.globalAlpha = alpha
                                if (o2.imageFlip) {
                                    ctx.translate(ox2, oy2)
                                    ctx.scale(-1, 1)
                                    ctx.drawImage(src, -sz2, -sz2, sz2 * 2, sz2 * 2)
                                } else {
                                    ctx.drawImage(src, ox2 - sz2, oy2 - sz2, sz2 * 2, sz2 * 2)
                                }
                                ctx.restore()
                            }
                            paintBody(1)

                            // Sun: red/dark at rise & set ↔ bright/yellow at zenith
                            if (o2.name === "Sun") {
                                var elev = Math.max(0, Math.min(1, (hy - oy2) / Math.max(1, R)))
                                // Also bias by day-frac (near 0 = rise, 1 = set)
                                var dayF = Math.max(0, Math.min(1, o2.frac))
                                var edgeDay = Math.max(0, 1 - Math.min(dayF, 1 - dayF) * 4) // 1 at ends
                                var low = Math.max(1 - elev * 1.35, edgeDay * 0.85)
                                low = Math.max(0, Math.min(1, low))

                                ctx.save()
                                ctx.beginPath()
                                ctx.arc(ox2, oy2, sz2 * 0.98, 0, Math.PI * 2)
                                ctx.clip()

                                if (low > 0.04) {
                                    // Darken + deep red/orange near horizon
                                    ctx.globalCompositeOperation = "source-atop"
                                    ctx.fillStyle = "rgba(40,8,0," + (low * 0.42) + ")"
                                    ctx.fillRect(ox2 - sz2, oy2 - sz2, sz2 * 2, sz2 * 2)
                                    ctx.fillStyle = "rgba(220,45,5," + (low * 0.55) + ")"
                                    ctx.fillRect(ox2 - sz2, oy2 - sz2, sz2 * 2, sz2 * 2)
                                    ctx.fillStyle = "rgba(255,100,20," + (low * 0.22) + ")"
                                    ctx.fillRect(ox2 - sz2, oy2 - sz2, sz2 * 2, sz2 * 2)
                                }

                                if (elev > 0.35 && low < 0.5) {
                                    // Yellow-bright lift toward zenith
                                    var boost = ((elev - 0.35) / 0.65) * (1 - low)
                                    ctx.globalCompositeOperation = "lighter"
                                    ctx.globalAlpha = 0.12 + 0.38 * boost
                                    ctx.drawImage(src, ox2 - sz2, oy2 - sz2, sz2 * 2, sz2 * 2)
                                    // Warm yellow wash at peak
                                    ctx.globalAlpha = 0.08 + 0.18 * boost
                                    ctx.fillStyle = "rgba(255,230,120,1)"
                                    ctx.fillRect(ox2 - sz2, oy2 - sz2, sz2 * 2, sz2 * 2)
                                }
                                ctx.restore()
                            }

                            // Soft horizon tint for Moon
                            if (o2.name === "Moon") {
                                var horizonDist = (hy - oy2) / R
                                var tint = Math.max(0, 1 - horizonDist * 4)
                                if (tint > 0.05) {
                                    ctx.save()
                                    ctx.beginPath()
                                    ctx.arc(ox2, oy2, sz2 * 0.92, 0, Math.PI * 2)
                                    ctx.clip()
                                    ctx.fillStyle = "rgba(200,40,10," + (tint * 0.35) + ")"
                                    ctx.fillRect(ox2 - sz2, oy2 - sz2, sz2 * 2, sz2 * 2)
                                    ctx.restore()
                                }
                            }
                        } else {
                            var g2 = ctx.createRadialGradient(ox2, oy2, 0, ox2, oy2, sz2 * 3.5)
                            g2.addColorStop(0, o2.halo || "rgba(255,255,255,0.15)")
                            g2.addColorStop(1, "rgba(0,0,0,0)")
                            ctx.beginPath()
                            ctx.arc(ox2, oy2, sz2 * 3.5, 0, Math.PI * 2)
                            ctx.fillStyle = g2
                            ctx.fill()
                            ctx.beginPath()
                            ctx.arc(ox2, oy2, sz2, 0, Math.PI * 2)
                            ctx.fillStyle = o2.color
                            ctx.fill()
                        }
                    }

                    ctx.restore()
                    // No below-horizon fill — glass continues uninterrupted into tabloid strip
                }
            }

            // Live clock (Text, not Canvas) so it always tracks scrub offset
            Text {
                id: skyClock
                z: 5
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 16
                anchors.rightMargin: 16
                color: "#ebffffff"
                font.pixelSize: Math.max(22, Math.round(Math.min(parent.width, parent.height) * 0.07))
                font.weight: Font.DemiBold
                text: {
                    var _ = root.skyPaintTick  // rebind on every scrub tick
                    var d = new Date(Date.now() + root.timeOffsetHours * 3600000)
                    var hh = d.getHours()
                    var mm = d.getMinutes()
                    return (hh < 10 ? "0" : "") + hh + ":" + (mm < 10 ? "0" : "") + mm
                }
            }

            // Glass time scrubber: −72 h … +72 h, 1 h steps
            // Hover + mouse wheel / touchpad scroll only (no click-drag).
            // Center = present; auto-snaps after 60 s idle.
            Item {
                id: scrubBar
                z: 10
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: infoPanel.top
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                anchors.bottomMargin: 2
                height: 28

                property bool hovered: scrubHover.containsMouse
                property int hours: root.timeOffsetHours

                function applyHours(h) {
                    var v = Math.round(h)
                    if (v < -72) v = -72
                    if (v > 72) v = 72
                    root.setTimeOffsetHours(v)
                    skyCanvas.requestPaint()
                    if (v === 0)
                        snapBackTimer.stop()
                    else
                        snapBackTimer.restart()
                }

                function nudgeHours(delta) {
                    applyHours(root.timeOffsetHours + delta)
                }

                // Soft glass track
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 3
                    radius: 1.5
                    color: Qt.rgba(1, 1, 1, scrubBar.hovered ? 0.22 : 0.10)
                    border.color: Qt.rgba(1, 1, 1, scrubBar.hovered ? 0.18 : 0.06)
                    border.width: 1
                }

                // Center tick (present)
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: 8
                    color: Qt.rgba(1, 1, 1, 0.20)
                }

                // Handle (position only — not draggable)
                Rectangle {
                    id: scrubHandle
                    width: 12
                    height: 12
                    radius: 6
                    anchors.verticalCenter: parent.verticalCenter
                    x: {
                        var t = (scrubBar.hours + 72) / 144
                        return t * (scrubBar.width - width)
                    }
                    color: Qt.rgba(1, 1, 1, scrubBar.hovered ? 0.45 : 0.28)
                    border.color: Qt.rgba(1, 1, 1, 0.35)
                    border.width: 1
                    opacity: scrubBar.hovered ? 0.95 : 0.55
                }

                // Hover + wheel; click resets to present (0). No custom cursor.
                MouseArea {
                    id: scrubHover
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    preventStealing: true
                    propagateComposedEvents: false
                    cursorShape: Qt.ArrowCursor
                    pressAndHoldInterval: 1000000
                    onPressed: function(mouse) { mouse.accepted = true }
                    onReleased: function(mouse) { mouse.accepted = true }
                    onPressAndHold: function(mouse) {
                        mouse.accepted = true
                        full.cancelAppletEdit()
                    }
                    onClicked: function(mouse) {
                        // Single click → now (same as idle snap, immediate)
                        scrubBar.applyHours(0)
                        mouse.accepted = true
                    }
                    onDoubleClicked: function(mouse) { mouse.accepted = true }
                    onWheel: function(wheel) {
                        // Fallback path (some stacks deliver wheel to MouseArea)
                        var dy = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y
                               : (wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y : 0)
                        if (dy === 0) {
                            wheel.accepted = false
                            return
                        }
                        // Scroll up / finger up → later time (+h); down → earlier (−h)
                        var steps = dy > 0 ? 1 : -1
                        if (Math.abs(dy) >= 120)
                            steps = Math.round(dy / 120)
                        if (steps === 0)
                            steps = dy > 0 ? 1 : -1
                        scrubBar.nudgeHours(steps)
                        wheel.accepted = true
                    }
                }

                // Preferred: WheelHandler (mouse wheel + touchpad scroll while hovered)
                WheelHandler {
                    id: scrubWheel
                    // active only when pointer is over the bar
                    enabled: scrubBar.hovered
                    acceptedDevices: PointerDevice.Mouse
                                     | PointerDevice.TouchPad
                    orientation: Qt.Vertical
                    property real _accum: 0
                    onWheel: function(event) {
                        // angleDelta: 120 per notch; pixelDelta: touchpad pixels
                        var dy = event.angleDelta.y
                        if (dy === 0)
                            dy = event.pixelDelta.y
                        if (dy === 0)
                            return
                        // Accumulate fractional touchpad motion into 1 h steps
                        scrubWheel._accum += dy
                        var stepUnit = event.pixelDelta.y !== 0 ? 40 : 120
                        while (scrubWheel._accum >= stepUnit) {
                            scrubBar.nudgeHours(1)
                            scrubWheel._accum -= stepUnit
                        }
                        while (scrubWheel._accum <= -stepUnit) {
                            scrubBar.nudgeHours(-1)
                            scrubWheel._accum += stepUnit
                        }
                        event.accepted = true
                    }
                }

                // Offset label while hovering with non-zero offset
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 1
                    visible: scrubBar.hovered && scrubBar.hours !== 0
                    text: (scrubBar.hours > 0 ? "+" : "") + scrubBar.hours + " h"
                    color: Qt.rgba(1, 1, 1, 0.55)
                    font.pixelSize: 10
                    font.bold: true
                }

                Timer {
                    id: snapBackTimer
                    interval: 60000
                    repeat: false
                    onTriggered: {
                        root.snapTimeToPresent()
                        skyCanvas.requestPaint()
                    }
                }
            }

            // Rise/set info strip (~2× card + type size)
            Item {
                id: infoPanel
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 104
                anchors.bottomMargin: 10
                z: 1

                onYChanged: skyCanvas.requestPaint()
                onHeightChanged: skyCanvas.requestPaint()

                // Always show all body tabloids (day and night); times reorder by cycle
                property var skyObjects: root.objects
                // Layout: equal gaps, equal side margins, never overflow right edge.
                // Ideal gap 5px — if sparse, shrink every gap by the same amount first.
                readonly property int tabloidMinSide: 16
                readonly property int tabloidIdealGap: 5
                readonly property int tabloidIdealCardW: 112
                readonly property int tabloidCount: skyObjects ? skyObjects.length : 0

                readonly property int tabloidGap: {
                    var n = tabloidCount
                    var W = width
                    if (n <= 1 || W <= 0)
                        return 0
                    var maxInner = Math.max(0, W - 2 * tabloidMinSide)
                    var cardW = tabloidIdealCardW
                    var gap = tabloidIdealGap
                    var need = n * cardW + (n - 1) * gap
                    if (need > maxInner)
                        gap = Math.max(0, Math.floor((maxInner - n * cardW) / (n - 1)))
                    return gap
                }

                readonly property int tabloidCardW: {
                    var n = tabloidCount
                    var W = width
                    if (n <= 0 || W <= 0)
                        return tabloidIdealCardW
                    var maxInner = Math.max(0, W - 2 * tabloidMinSide)
                    var gap = tabloidGap
                    var cardW = tabloidIdealCardW
                    if (n === 1)
                        return Math.min(cardW, maxInner)
                    var need = n * cardW + (n - 1) * gap
                    if (need > maxInner)
                        cardW = Math.max(36, Math.floor((maxInner - (n - 1) * gap) / n))
                    return cardW
                }

                readonly property int tabloidRowW: {
                    var n = tabloidCount
                    if (n <= 0)
                        return 0
                    return n * tabloidCardW + Math.max(0, n - 1) * tabloidGap
                }

                // Clip so nothing paints past the glass edge
                clip: true

                Row {
                    id: tabloidRow
                    anchors.verticalCenter: parent.verticalCenter
                    // Equal left/right remainder (always ≥ tabloidMinSide when fit math holds)
                    x: Math.max(0, Math.floor((infoPanel.width - infoPanel.tabloidRowW) / 2))
                    spacing: infoPanel.tabloidGap
                    width: infoPanel.tabloidRowW
                    height: 92

                    Repeater {
                        model: infoPanel.skyObjects

                        delegate: Item {
                            width: infoPanel.tabloidCardW
                            height: 92
                            // Day: rise (orange) then set (blue)
                            // Night: last set (blue) then next rise (orange)
                            readonly property bool night: modelData.aboveHorizon === false
                            readonly property var topTime: night ? modelData.setTime : modelData.riseTime
                            readonly property var botTime: night ? modelData.riseTime : modelData.setTime
                            readonly property color topColor: night ? "#7ec8ff" : "#ffc864"
                            readonly property color botColor: night ? "#ffc864" : "#7ec8ff"

                            Rectangle {
                                anchors.fill: parent
                                radius: Math.min(14, width * 0.12)
                                color: Qt.rgba(root.tabloidTint.r, root.tabloidTint.g,
                                               root.tabloidTint.b, root.tabloidTintAlpha)
                                border.color: night ? "#44a0ff88" : "#55ffffff"
                                border.width: 1
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                width: parent.width - 8

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    text: modelData.name
                                    color: night ? "#c8d0d8" : "#f2ffffff"
                                    font.pixelSize: Math.max(12, Math.min(18, infoPanel.tabloidCardW * 0.16))
                                    font.bold: true
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    text: topTime ? formatTime(topTime) : "--:--"
                                    color: topColor
                                    font.pixelSize: Math.max(11, Math.min(16, infoPanel.tabloidCardW * 0.14))
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    text: botTime ? formatTime(botTime) : "--:--"
                                    color: botColor
                                    font.pixelSize: Math.max(11, Math.min(16, infoPanel.tabloidCardW * 0.14))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Astronomy ─────────────────────────────────────────────────────

    function computeObjects() {
        var date = new Date(new Date().getTime() + root.timeOffsetHours * 3600000)
        try {
            var observer = new Astronomy.Observer(userLat, userLon, 0)
        } catch (e) {
            console.log("Astronomy not available:", e)
            return []
        }

        var bodyNames = ["Sun","Moon","Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune"]
        var result = []

        for (var i = 0; i < bodyNames.length; i++) {
            var name = bodyNames[i]
            var body = Astronomy.Body[name]
            var cfg  = iconConfig[name] || { mode: "color", color: "#ffffff", halo: "#33ffffff", size: 7 }

            var eq  = Astronomy.Equator(body, date, observer, true, true)
            var hor = Astronomy.Horizon(date, observer, eq.ra, eq.dec, "normal")
            var alt = hor.altitude
            var aboveHorizon = alt >= 0

            // Times for tabloids + arc frac:
            // Day:  riseTime = last rise, setTime = next set
            // Night: riseTime = next rise, setTime = last set  (UI swaps order + colors)
            var rise = null
            var set  = null
            var frac = 0

            if (aboveHorizon) {
                rise = Astronomy.SearchRiseSet(body, observer, +1, date, -1)
                set  = Astronomy.SearchRiseSet(body, observer, -1, date, +1)
                if (rise && set) {
                    var span = set.date.getTime() - rise.date.getTime()
                    frac = span > 0
                        ? (date.getTime() - rise.date.getTime()) / span
                        : 0.5
                } else {
                    frac = 0.5
                }
            } else {
                var lastSet  = Astronomy.SearchRiseSet(body, observer, -1, date, -1)
                var nextRise = Astronomy.SearchRiseSet(body, observer, +1, date, +1)
                set  = lastSet
                rise = nextRise
                // Frac outside [0,1] so paint skips the body (true night)
                if (lastSet) {
                    var prevRise = Astronomy.SearchRiseSet(body, observer, +1, lastSet.date, -1)
                    if (prevRise && lastSet) {
                        var daySpan = lastSet.date.getTime() - prevRise.date.getTime()
                        frac = daySpan > 0
                            ? (date.getTime() - prevRise.date.getTime()) / daySpan
                            : 1.5
                    } else {
                        frac = 1.5
                    }
                } else if (nextRise) {
                    frac = -0.5
                } else {
                    frac = 1.5
                }
            }

            var transit = Astronomy.SearchHourAngle(body, observer, 0, date, +1)
            var maxAlt  = (transit && transit.hor) ? transit.hor.altitude : Math.max(alt, 10)
            maxAlt = Math.max(5, Math.min(90, maxAlt))

            var moonImageIndex = 0
            if (name === "Moon") {
                var phase = Astronomy.MoonPhase(date)
                var phaseMap = [4, 3, 2, 1, 0, 7, 6, 5]
                moonImageIndex = phaseMap[Math.floor(phase / 45) % 8]
            }

            var saturnImageIndex = 4
            var saturnFlip = false
            if (name === "Saturn") {
                var illum = Astronomy.Illumination(body, date)
                var tilt = illum.ring_tilt || 0
                saturnFlip = tilt > 0
                saturnImageIndex = 4 - Math.min(4, Math.floor(Math.abs(tilt) / 6))
            }

            var jupiterImageIndex = 0
            var jupiterFlip = false
            if (name === "Jupiter") {
                var periodMs = 9.925 * 3600000
                var epochOffset = 9.5
                var epoch = new Date("2000-01-01T12:00:00Z").getTime() + epochOffset * 3600000
                var elapsed = date.getTime() - epoch
                var cml = ((-(elapsed % periodMs) / periodMs * 360) + 360) % 360
                var grsDist = Math.min(cml, 360 - cml)
                var pos = grsDist / 180
                if (pos < 0.5) {
                    var spotPos = pos * 2
                    var step = Math.floor(spotPos * 4)
                    jupiterImageIndex = 4 - step
                    jupiterFlip = cml > 180
                }
            }

            result.push({
                name: name,
                maxAlt: maxAlt,
                aboveHorizon: aboveHorizon,
                riseTime: rise ? rise.date : null,
                setTime:  set  ? set.date  : null,
                frac: frac,
                mode: cfg.mode,
                size: cfg.size * root.planetScale,
                color: cfg.color  || "#ffffff",
                halo:  cfg.halo   || "#33ffffff",
                image: cfg.image  || (cfg.images ? cfg.images[0] : ""),
                images: cfg.images || null,
                imageIndex: name === "Moon"    ? moonImageIndex
                          : name === "Saturn"  ? saturnImageIndex
                          : name === "Jupiter" ? jupiterImageIndex
                          : 0,
                imageFlip: name === "Jupiter" ? jupiterFlip
                         : name === "Saturn"  ? saturnFlip
                         : false
            })
        }
        return result
    }

    function formatTime(d) {
        var local = new Date(d.getTime())
        var hh = local.getHours()
        var mm = local.getMinutes()
        return (hh < 10 ? "0" : "") + hh + ":" + (mm < 10 ? "0" : "") + mm
    }

    function loadAllImages(canvas) {
        if (!canvas) return
        var allImages = [
            "Sun.png", "Mercury.png", "Venus.png",
            "Mars.png", "Uranus.png", "Neptune.png"
        ]
        var multi  = ["Moon", "Jupiter", "Saturn"]
        var counts = { Moon: 8, Jupiter: 5, Saturn: 5 }
        for (var m = 0; m < multi.length; m++) {
            var nm = multi[m]
            for (var k = 0; k < counts[nm]; k++)
                allImages.push(nm + k + ".png")
        }
        for (var n = 0; n < allImages.length; n++)
            canvas.loadImage(iconUrl(allImages[n]))
    }
}
