import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-theme"
        source: "config/ConfigAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Calendar")
        icon: "view-calendar"
        source: "config/ConfigGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Holidays")
        icon: "view-calendar-holiday"
        source: "config/ConfigHolidays.qml"
    }
}
