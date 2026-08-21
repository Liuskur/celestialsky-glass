// SPDX-License-Identifier: MIT
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root

    property alias cfg_firstDayOfWeek: firstDayCombo.currentIndex
    property alias cfg_showWeekNumbers: weekNumbers.checked
    property var cfg_enabledCalendarPlugins
    property int cfg_eventLookaheadDays: 14
    property int cfg_eventLookaheadDaysDefault: 14
    property bool _ready: false

    ComboBox {
        id: firstDayCombo
        Kirigami.FormData.label: i18n("First day of week:")
        model: [
            i18n("Sunday"),
            i18n("Monday"),
            i18n("Tuesday"),
            i18n("Wednesday"),
            i18n("Thursday"),
            i18n("Friday"),
            i18n("Saturday")
        ]
    }

    CheckBox {
        id: weekNumbers
        Kirigami.FormData.label: i18n("Week numbers:")
        text: i18n("Show")
    }

    CheckBox {
        id: holidays
        Kirigami.FormData.label: i18n("Holidays:")
        text: i18n("Show regional holidays")
        checked: cfg_enabledCalendarPlugins.indexOf("holidaysevents") !== -1
        onToggled: root._syncPlugins()
    }

    CheckBox {
        id: astronomical
        Kirigami.FormData.label: i18n("Sky events:")
        text: i18n("Show astronomical events")
        checked: cfg_enabledCalendarPlugins.indexOf("astronomicalevents") !== -1
        onToggled: root._syncPlugins()
    }

    function _syncPlugins() {
        var list = []
        if (holidays.checked)
            list.push("holidaysevents")
        if (astronomical.checked)
            list.push("astronomicalevents")
        cfg_enabledCalendarPlugins = list
    }
}
