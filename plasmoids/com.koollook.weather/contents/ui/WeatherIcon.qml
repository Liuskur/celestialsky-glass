// SPDX-License-Identifier: MIT
import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.Icon {
    id: ico
    property string iconName: "weather-none-available"
    source: iconName
    isMask: true
    color: {
        var n = iconName || ""
        if (n.indexOf("clear-night") !== -1)
            return "#e7bf7e"
        if (n.indexOf("clear") !== -1)
            return "#f5c518"
        if (n.indexOf("few-clouds-night") !== -1)
            return "#d4b87a"
        if (n.indexOf("few-clouds") !== -1)
            return "#f0c85a"
        if (n.indexOf("storm") !== -1)
            return "#9aa6ff"
        if (n.indexOf("snow") !== -1)
            return "#dce9f7"
        if (n.indexOf("showers-scattered") !== -1)
            return "#7ec0f2"
        if (n.indexOf("showers") !== -1 || n.indexOf("rain") !== -1)
            return "#4a9ee0"
        if (n.indexOf("fog") !== -1)
            return "#9aa8b5"
        if (n.indexOf("clouds") !== -1)
            return "#c5d0da"
        return "#f4f1e8"
    }
}
