import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-theme"
        source: "config/ConfigAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Sky")
        icon: "weather-clear-night"
        source: "config/ConfigGeneral.qml"
    }
}
