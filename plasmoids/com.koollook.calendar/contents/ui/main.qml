// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.workspace.calendar as PlasmaCalendar
import "org/koollook/glass"

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    switchWidth: Kirigami.Units.gridUnit * 12
    switchHeight: Kirigami.Units.gridUnit * 12

    property date today: new Date()

    KoollookColors {
        id: colors
        styleMode: Plasmoid.configuration.styleMode
        appearance: Plasmoid.configuration.appearance
    }

    function pluginIds() {
        var p = Plasmoid.configuration.enabledCalendarPlugins
        if (p === undefined || p === null || p === "")
            return ["holidaysevents", "astronomicalevents"]
        if (typeof p === "string")
            return p.split(",").filter(function (s) { return s.length > 0 })
        var a = []
        var i
        for (i = 0; i < p.length; i++)
            a.push(p[i])
        return a
    }

    readonly property int lookaheadDays: {
        var n = Plasmoid.configuration.eventLookaheadDays
        if (n === 7 || n === 14 || n === 30 || n === 60)
            return n
        return 14
    }

    readonly property int firstDow: Plasmoid.configuration.firstDayOfWeek

    PlasmaCalendar.EventPluginsManager {
        id: eventPlugins
        enabledPlugins: root.pluginIds()
        Component.onCompleted: populateEnabledPluginsList(root.pluginIds())
        onPluginsChanged: initialLoad.restart()
    }

    PlasmaCalendar.Calendar {
        id: cal0
        days: 7
        weeks: 6
        firstDayOfWeek: root.firstDow
        today: root.today
        Component.onCompleted: daysModel.setPluginsManager(eventPlugins)
    }
    PlasmaCalendar.Calendar {
        id: cal1
        days: 7
        weeks: 6
        firstDayOfWeek: root.firstDow
        today: root.today
        Component.onCompleted: {
            daysModel.setPluginsManager(eventPlugins)
            var d = new Date(root.today.getFullYear(), root.today.getMonth() + 1, 1)
            goToYearAndMonth(d.getFullYear(), d.getMonth() + 1)
        }
    }
    PlasmaCalendar.Calendar {
        id: cal2
        days: 7
        weeks: 6
        firstDayOfWeek: root.firstDow
        today: root.today
        Component.onCompleted: {
            daysModel.setPluginsManager(eventPlugins)
            var d = new Date(root.today.getFullYear(), root.today.getMonth() + 2, 1)
            goToYearAndMonth(d.getFullYear(), d.getMonth() + 1)
        }
    }

    function _daysModelForDate(d) {
        var y = d.getFullYear()
        var m = d.getMonth()
        if (y === cal0.year && m === cal0.month - 1)
            return cal0.daysModel
        if (y === cal1.year && m === cal1.month - 1)
            return cal1.daysModel
        return cal2.daysModel
    }

    function _pillColor(ev) {
        var c = ev.eventColor ? ev.eventColor.toString() : ""
        if (c.length > 0 && c !== "#000000" && c !== "#00000000")
            return c
        if (ev.eventType === "Holiday")
            return "#FF6B6B"
        if (ev.eventType === "Todo")
            return "#FF9500"
        if (ev.eventType === "Journal")
            return "#34C759"
        return colors.todayAccent
    }

    function _formatTime(ev) {
        if (ev.isAllDay)
            return i18n("All day")
        if (!ev.startDateTime)
            return ""
        return Qt.formatTime(ev.startDateTime, "hh:mm")
    }

    ListModel { id: eventsModel }

    function rebuildEvents() {
        eventsModel.clear()
        var now = new Date()
        var todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        var weekEndDay = todayStart.getDay()
        var daysUntilNextWeek
        if (firstDow === 1)
            daysUntilNextWeek = weekEndDay === 0 ? 1 : (8 - weekEndDay)
        else
            daysUntilNextWeek = weekEndDay === 0 ? 7 : (7 - weekEndDay)
        var weekEnd = new Date(todayStart.getTime() + daysUntilNextWeek * 86400000)
        var lookaheadEnd = new Date(todayStart.getTime() + lookaheadDays * 86400000)
        var todayEvents = []
        var weekEvents = []
        var upcomingEvents = []
        var seen = ({})
        var d, dm, raw, ei, events, i, ev, key, entry, dTime
        for (d = new Date(todayStart); d < lookaheadEnd; d = new Date(d.getTime() + 86400000)) {
            dm = _daysModelForDate(d)
            if (!dm || !dm.eventsForDate)
                continue
            raw = dm.eventsForDate(d)
            if (!raw || raw.length === 0)
                continue
            events = []
            for (ei = 0; ei < raw.length; ei++)
                events.push(raw[ei])
            events.sort(function (a, b) {
                if (a.isAllDay && !b.isAllDay)
                    return -1
                if (!a.isAllDay && b.isAllDay)
                    return 1
                var at = a.startDateTime ? a.startDateTime.getTime() : 0
                var bt = b.startDateTime ? b.startDateTime.getTime() : 0
                return at - bt
            })
            for (i = 0; i < events.length; i++) {
                ev = events[i]
                key = (ev.title || "") + "|" + (ev.startDateTime ? ev.startDateTime.getTime() : 0)
                if (seen[key])
                    continue
                seen[key] = true
                entry = {
                    isHeader: false,
                    title: ev.title || "",
                    pillColor: _pillColor(ev),
                    timeLabel: ""
                }
                dTime = d.getTime()
                if (dTime === todayStart.getTime()) {
                    entry.timeLabel = _formatTime(ev)
                    todayEvents.push(entry)
                } else if (d < weekEnd) {
                    entry.timeLabel = Qt.formatDate(d, "ddd d")
                    weekEvents.push(entry)
                } else {
                    entry.timeLabel = Qt.formatDate(d, "MMM d")
                    upcomingEvents.push(entry)
                }
            }
        }
        function appendSection(title, list) {
            var n
            if (!list.length)
                return
            eventsModel.append({ isHeader: true, title: title, pillColor: "", timeLabel: "" })
            for (n = 0; n < list.length; n++)
                eventsModel.append(list[n])
        }
        appendSection(i18n("Events today"), todayEvents)
        appendSection(i18n("This week"), weekEvents)
        appendSection(i18n("Upcoming"), upcomingEvents)
    }

    Timer {
        id: rebuildDebounce
        interval: 120
        repeat: false
        onTriggered: root.rebuildEvents()
    }

    Timer {
        id: initialLoad
        interval: 700
        repeat: false
        onTriggered: root.rebuildEvents()
    }

    Connections {
        target: cal0.daysModel
        function onAgendaUpdated() { rebuildDebounce.restart() }
    }
    Connections {
        target: cal1.daysModel
        function onAgendaUpdated() { rebuildDebounce.restart() }
    }
    Connections {
        target: cal2.daysModel
        function onAgendaUpdated() { rebuildDebounce.restart() }
    }
    Connections {
        target: Plasmoid.configuration
        function onEnabledCalendarPluginsChanged() {
            eventPlugins.enabledPlugins = root.pluginIds()
            eventPlugins.populateEnabledPluginsList(root.pluginIds())
            initialLoad.restart()
        }
        function onEventLookaheadDaysChanged() { rebuildDebounce.restart() }
        function onFirstDayOfWeekChanged() { rebuildDebounce.restart() }
    }

    Component.onCompleted: initialLoad.start()

    fullRepresentation: Item {
        id: calRoot
        Layout.preferredWidth: Kirigami.Units.gridUnit * 32
        Layout.preferredHeight: Kirigami.Units.gridUnit * 18
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 14
        clip: true
        readonly property bool showEvents: width >= Kirigami.Units.gridUnit * 24

        KoollookFrame { anchors.fill: parent }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Math.max(Kirigami.Units.largeSpacing,
                Plasmoid.configuration.hideFrame ? Kirigami.Units.smallSpacing
                    : Math.min(28, (Plasmoid.configuration.cornerRadius || 48) * 0.18))
            spacing: Kirigami.Units.largeSpacing

            Item {
                visible: calRoot.showEvents
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                Layout.minimumWidth: Kirigami.Units.gridUnit * 10

                ListView {
                    id: eventsList
                    anchors.fill: parent
                    clip: true
                    spacing: 4
                    model: eventsModel
                    delegate: eventDelegate
                    visible: eventsModel.count > 0
                }

                PlasmaComponents.Label {
                    anchors.centerIn: parent
                    visible: eventsModel.count === 0
                    text: i18n("No upcoming events")
                    color: colors.foreground
                    opacity: 0.4
                    wrapMode: Text.WordWrap
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                spacing: 0

                PlasmaCalendar.MonthView {
                    id: monthView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    today: root.today
                    showWeekNumbers: Plasmoid.configuration.showWeekNumbers
                    firstDayOfWeek: Plasmoid.configuration.firstDayOfWeek
                    eventPluginsManager: eventPlugins
                    Component.onCompleted: {
                        if (daysModel)
                            daysModel.setPluginsManager(eventPlugins)
                    }
                    Connections {
                        target: eventPlugins
                        function onPluginsChanged() {
                            if (monthView.daysModel)
                                monthView.daysModel.setPluginsManager(eventPlugins)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: eventDelegate
        Item {
            width: ListView.view ? ListView.view.width : 100
            height: model.isHeader ? Kirigami.Units.gridUnit * 1.1 : Kirigami.Units.gridUnit * 1.5

            PlasmaComponents.Label {
                visible: model.isHeader
                anchors.fill: parent
                text: model.title
                color: colors.foreground
                opacity: 0.55
                font.weight: Font.DemiBold
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                verticalAlignment: Text.AlignBottom
            }

            EventCard {
                visible: !model.isHeader
                anchors.fill: parent
                title: model.title
                timeLabel: model.timeLabel
                pillColor: model.pillColor || colors.todayAccent
                textColor: colors.foreground
            }
        }
    }
}
