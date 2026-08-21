// SPDX-License-Identifier: MIT
// Same icon names and full-color glyphs as Plasma Weather Report (Breeze weather-*).
import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.Icon {
    property string iconName: "weather-none-available"
    source: iconName && iconName.length ? iconName : "weather-none-available"
    isMask: false
}
