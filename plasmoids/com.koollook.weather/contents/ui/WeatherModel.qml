// SPDX-License-Identifier: MIT
import QtQuick

QtObject {
    id: root

    property real latitude: 0
    property real longitude: 0
    property int temperatureUnit: 0
    property bool loading: false
    property string error: ""
    property bool hasData: false

    property real temperature: 0
    property real feelsLike: 0
    property real humidity: 0
    property real pressure: 0
    property real windSpeed: 0
    property int windDir: 0
    property int weatherCode: 0
    property bool isNight: false
    property string conditionText: ""
    property string iconName: "weather-none-available"
    property var daily: []
    property var hourly: []
    property string updatedAt: ""

    property int _reqId: 0

    function refresh() {
        if (!(latitude || longitude) && latitude !== 0)
            return
        var reqId = ++_reqId
        loading = true
        error = ""
        var url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + latitude
            + "&longitude=" + longitude
            + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,pressure_msl,wind_speed_10m,wind_direction_10m,is_day"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum"
            + "&hourly=temperature_2m,weather_code,is_day"
            + "&forecast_days=6&forecast_hours=24&timezone=auto"
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (reqId !== root._reqId) return
            loading = false
            if (xhr.status !== 200) {
                error = i18n("Could not load forecast")
                return
            }
            try {
                root._apply(JSON.parse(xhr.responseText))
            } catch (e) {
                error = i18n("Could not read forecast")
            }
        }
        xhr.open("GET", url)
        xhr.send()
    }

    function formatTemp(celsius) {
        var v = temperatureUnit === 1 ? (celsius * 9 / 5 + 32) : celsius
        return Math.round(v) + "°"
    }

    function windArrow() {
        var dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        return dirs[Math.round(windDir / 45) % 8]
    }

    function _icon(code, night) {
        if (code === 0) return night ? "weather-clear-night" : "weather-clear"
        if (code === 1 || code === 2) return night ? "weather-few-clouds-night" : "weather-few-clouds"
        if (code === 3) return "weather-clouds"
        if (code === 45 || code === 48) return "weather-fog"
        if (code >= 51 && code <= 57) return "weather-showers-scattered"
        if (code >= 61 && code <= 67) return "weather-showers"
        if (code >= 71 && code <= 77) return "weather-snow"
        if (code >= 80 && code <= 82) return "weather-showers"
        if (code >= 85 && code <= 86) return "weather-snow"
        if (code >= 95) return "weather-storm"
        return "weather-none-available"
    }

    function _condition(code) {
        if (code === 0) return i18n("Clear")
        if (code === 1) return i18n("Mainly clear")
        if (code === 2) return i18n("Partly cloudy")
        if (code === 3) return i18n("Overcast")
        if (code === 45 || code === 48) return i18n("Fog")
        if (code >= 51 && code <= 57) return i18n("Drizzle")
        if (code >= 61 && code <= 67) return i18n("Rain")
        if (code >= 71 && code <= 77) return i18n("Snow")
        if (code >= 80 && code <= 82) return i18n("Showers")
        if (code >= 85 && code <= 86) return i18n("Snow showers")
        if (code >= 95) return i18n("Thunderstorm")
        return i18n("Unknown")
    }

    function _apply(resp) {
        var cur = resp.current || {}
        temperature = cur.temperature_2m || 0
        feelsLike = cur.apparent_temperature || 0
        humidity = cur.relative_humidity_2m || 0
        pressure = cur.pressure_msl || 0
        windSpeed = cur.wind_speed_10m || 0
        windDir = cur.wind_direction_10m || 0
        weatherCode = cur.weather_code || 0
        isNight = cur.is_day === 0
        conditionText = _condition(weatherCode)
        iconName = _icon(weatherCode, isNight)
        updatedAt = cur.time || ""

        var d = resp.daily || {}
        var times = d.time || []
        var days = []
        for (var i = 0; i < times.length && i < 6; i++) {
            var dt = new Date(times[i] + "T12:00:00")
            days.push({
                name: Qt.locale().dayName(dt.getDay(), Locale.ShortFormat),
                icon: _icon(d.weather_code[i], false),
                high: formatTemp(d.temperature_2m_max[i]),
                low: formatTemp(d.temperature_2m_min[i])
            })
        }
        daily = days

        var h = resp.hourly || {}
        var ht = h.time || []
        var hours = []
        var now = Date.now()
        for (var j = 0; j < ht.length && hours.length < 12; j++) {
            var hd = new Date(ht[j])
            if (hd.getTime() + 3600000 < now)
                continue
            hours.push({
                label: Qt.formatTime(hd, "HH:mm"),
                icon: _icon(h.weather_code[j], h.is_day[j] === 0),
                temp: formatTemp(h.temperature_2m[j])
            })
        }
        hourly = hours
        hasData = true
    }
}
