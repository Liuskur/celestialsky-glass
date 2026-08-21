// SPDX-License-Identifier: MIT
// Default: Open-Meteo (former macOS weather widget). Optional: Plasma ions (BBC, NOAA, DWD, wetter.com, EnvCan).
import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

QtObject {
    id: root

    property string source: "openmeteo"
    property real latitude: 59.43696
    property real longitude: 24.75353
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
    property string windDirText: ""
    property int weatherCode: 0
    property bool isNight: false
    property string conditionText: ""
    property string iconName: "weather-none-available"
    property string credit: ""
    property var daily: []
    property var hourly: []
    property var todaySlots: []
    readonly property var slotHours: [6, 9, 12, 15, 18, 21]

    property int _reqId: 0
    property var engine: Plasma5Support.DataSource {
        engine: "weather"
        interval: 30 * 60 * 1000
        connectedSources: root._isOm() || !root.source.length ? [] : [root.source]
        onNewData: function (sourceName, data) {
            if (sourceName !== root.source)
                return
            root._applyEngine(data)
        }
    }

    function _isOm() {
        return !source.length || source === "openmeteo" || source.indexOf("openmeteo|") === 0
    }

    function refresh() {
        loading = true
        error = ""
        if (_isOm()) {
            _fetchOpenMeteo()
            return
        }
        if (!source.length) {
            error = i18n("Pick a weather station")
            loading = false
            return
        }
        engine.disconnectSource(source)
        engine.removeSource(source)
        engine.connectSource(source)
        if (source.indexOf("bbcukmet|") === 0)
            _fetchBbc()
        fallbackTimer.restart()
    }

    property var fallbackTimer: Timer {
        interval: 4000
        repeat: false
        onTriggered: {
            if (root.hasData)
                return
            if (root.source.indexOf("bbcukmet|") === 0)
                root._fetchBbc()
            else
                root.loading = false
        }
    }
    }

    function formatTemp(celsius) {
        var v = temperatureUnit === 1 ? (celsius * 9 / 5 + 32) : celsius
        return Math.round(v) + "°"
    }

    function windArrow() {
        if (windDirText.length)
            return windDirText
        var dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        return dirs[Math.round(windDir / 45) % 8]
    }

    function _toC(value, unit) {
        if (value === undefined || value === null || value === "")
            return 0
        var n = parseFloat(value)
        if (isNaN(n))
            return 0
        if (unit === 6002)
            return (n - 32) * 5 / 9
        if (unit === 6000)
            return n - 273.15
        return n
    }

    function _applyEngine(d) {
        if (!d)
            return
        var unit = d["Temperature Unit"]
        if (d["Temperature"] === undefined && d["Current Conditions"] === undefined
                && d["Short Forecast Day 0"] === undefined)
            return
        temperature = _toC(d["Temperature"], unit)
        feelsLike = _toC(d["Windchill"] !== undefined ? d["Windchill"] : d["Heat Index"], unit) || temperature
        humidity = parseFloat(d["Humidity"]) || 0
        pressure = parseFloat(d["Pressure"]) || 0
        windSpeed = parseFloat(d["Wind Speed"]) || 0
        windDirText = d["Wind Direction"] || ""
        conditionText = d["Current Conditions"] || ""
        iconName = d["Condition Icon"] || "weather-none-available"
        credit = d["Credit"] || ""
        var days = []
        var n = parseInt(d["Total Weather Days"] || "7", 10)
        var i
        for (i = 0; i < n && i < 8; i++) {
            var raw = d["Short Forecast Day " + i]
            if (!raw)
                continue
            var t = ("" + raw).split("|")
            var icon = t.length > 1 ? t[1] : "weather-none-available"
            days.push({
                name: t[0] || "",
                icon: icon,
                high: t.length > 3 ? formatTemp(_toC(t[3], unit)) : "—",
                low: t.length > 4 ? formatTemp(_toC(t[4], unit)) : "—",
                slots: [{ hour: 12, label: "12", icon: icon, temp: t.length > 3 ? formatTemp(_toC(t[3], unit)) : "—" }]
            })
        }
        if (days.length)
            daily = days
        if (conditionText.length || days.length) {
            hasData = true
            loading = false
            error = ""
        }
    }

    function _bbcIcon(type) {
        var n = parseInt(type, 10)
        if (n === 0 || n === 1) return isNight ? "weather-clear-night" : "weather-clear"
        if (n >= 2 && n <= 4) return isNight ? "weather-few-clouds-night" : "weather-few-clouds"
        if (n >= 5 && n <= 8) return "weather-clouds"
        if (n === 9 || n === 10 || n === 11 || n === 12) return "weather-showers-scattered"
        if (n >= 13 && n <= 18) return "weather-showers"
        if (n >= 19 && n <= 22) return "weather-snow"
        if (n >= 23 && n <= 30) return "weather-storm"
        return "weather-none-available"
    }

    function _fetchBbc() {
        var parts = source.split("|")
        var id = parts[parts.length - 1]
        if (!id || !/^[0-9]+$/.test(id))
            return
        var reqId = ++_reqId
        var xhr = new XMLHttpRequest()
        var url = "https://weather-broker-cdn.api.bbci.co.uk/en/forecast/aggregated/" + id
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            if (reqId !== root._reqId)
                return
            if (xhr.status !== 200) {
                if (!root.hasData) {
                    loading = false
                    error = i18n("Could not load forecast")
                }
                return
            }
            try {
                root._applyBbc(JSON.parse(xhr.responseText))
            } catch (e) {
                if (!root.hasData) {
                    loading = false
                    error = i18n("Could not read forecast")
                }
            }
        }
        xhr.open("GET", url)
        xhr.send()
    }

    function _applyBbc(j) {
        var forecasts = j.forecasts || []
        if (!forecasts.length)
            return
        isNight = !!j.isNight
        var today = forecasts[0]
        var sum = (today.summary && today.summary.report) ? today.summary.report : {}
        var reports = (today.detailed && today.detailed.reports) ? today.detailed.reports : []
        var nowR = reports.length ? reports[0] : sum
        temperature = nowR.temperatureC || sum.maxTempC || 0
        feelsLike = nowR.feelsLikeTemperatureC || temperature
        humidity = nowR.humidity || 0
        pressure = nowR.pressure || 0
        windSpeed = nowR.windSpeedKph || sum.windSpeedKph || 0
        windDirText = nowR.windDirectionAbbreviation || sum.windDirectionAbbreviation || ""
        conditionText = nowR.weatherTypeText || sum.weatherTypeText || ""
        iconName = _bbcIcon(nowR.weatherType !== undefined ? nowR.weatherType : sum.weatherType)
        credit = "BBC Weather"
        var hours = []
        var r, ts, hh, hnum
        for (r = 0; r < reports.length; r++) {
            ts = reports[r].timeslot || ""
            hh = parseInt(ts.split(":")[0], 10)
            if (slotHours.indexOf(hh) < 0)
                continue
            hours.push({
                label: (hh < 10 ? "0" : "") + hh,
                icon: _bbcIcon(reports[r].weatherType),
                temp: formatTemp(reports[r].temperatureC)
            })
        }
        hourly = hours
        todaySlots = hours
        var days = []
        var d, rep, srep, dt, ymd, slots, s, hour, hit
        for (d = 0; d < forecasts.length && days.length < 7; d++) {
            srep = (forecasts[d].summary && forecasts[d].summary.report) ? forecasts[d].summary.report : {}
            ymd = srep.localDate || ""
            dt = ymd ? new Date(ymd + "T12:00:00") : new Date()
            rep = (forecasts[d].detailed && forecasts[d].detailed.reports) ? forecasts[d].detailed.reports : []
            slots = []
            for (s = 0; s < slotHours.length; s++) {
                hour = slotHours[s]
                hit = null
                for (r = 0; r < rep.length; r++) {
                    hnum = parseInt((rep[r].timeslot || "99").split(":")[0], 10)
                    if (hnum === hour) {
                        hit = rep[r]
                        break
                    }
                }
                slots.push({
                    hour: hour,
                    label: (hour < 10 ? "0" : "") + hour,
                    icon: hit ? _bbcIcon(hit.weatherType) : _bbcIcon(srep.weatherType),
                    temp: hit ? formatTemp(hit.temperatureC) : "—"
                })
            }
            days.push({
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

    function _fetchOpenMeteo() {
        var reqId = ++_reqId
        var url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + latitude
            + "&longitude=" + longitude
            + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,pressure_msl,wind_speed_10m,wind_direction_10m,is_day"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum"
            + "&hourly=temperature_2m,weather_code,is_day"
            + "&forecast_days=7&timezone=auto"
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            if (reqId !== root._reqId)
                return
            loading = false
            if (xhr.status !== 200) {
                error = i18n("Could not load forecast")
                return
            }
            try {
                root._applyOm(JSON.parse(xhr.responseText))
            } catch (e) {
                error = i18n("Could not read forecast")
            }
        }
        xhr.open("GET", url)
        xhr.send()
    }

    function _applyOm(resp) {
        var cur = resp.current || {}
        temperature = cur.temperature_2m || 0
        feelsLike = cur.apparent_temperature || 0
        humidity = cur.relative_humidity_2m || 0
        pressure = cur.pressure_msl || 0
        windSpeed = cur.wind_speed_10m || 0
        windDir = cur.wind_direction_10m || 0
        windDirText = ""
        weatherCode = cur.weather_code || 0
        isNight = cur.is_day === 0
        conditionText = _condition(weatherCode)
        iconName = _icon(weatherCode, isNight)
        credit = "Open-Meteo"
        var d = resp.daily || {}
        var times = d.time || []
        var h = resp.hourly || {}
        var ht = h.time || []
        var byKey = ({})
        for (var j = 0; j < ht.length; j++) {
            var hd = new Date(ht[j])
            var key = hd.getFullYear() + "-" + ("0" + (hd.getMonth() + 1)).slice(-2)
                + "-" + ("0" + hd.getDate()).slice(-2) + "-" + hd.getHours()
            byKey[key] = {
                icon: _icon(h.weather_code[j], h.is_day[j] === 0),
                temp: formatTemp(h.temperature_2m[j]),
                at: hd
            }
        }
        function slotsFor(ymd) {
            var slots = []
            for (var s = 0; s < root.slotHours.length; s++) {
                var hour = root.slotHours[s]
                var hit = byKey[ymd + "-" + hour]
                slots.push({
                    hour: hour,
                    label: (hour < 10 ? "0" : "") + hour,
                    icon: hit ? hit.icon : "weather-none-available",
                    temp: hit ? hit.temp : "—"
                })
            }
            return slots
        }
        var days = []
        for (var i = 0; i < times.length && i < 7; i++) {
            var dt = new Date(times[i] + "T12:00:00")
            var ymd = times[i]
            var noon = byKey[ymd + "-12"] || byKey[ymd + "-15"]
            days.push({
                name: Qt.locale().dayName(dt.getDay(), Locale.ShortFormat),
                ymd: ymd,
                icon: noon ? noon.icon : _icon(d.weather_code[i], false),
                high: formatTemp(d.temperature_2m_max[i]),
                low: formatTemp(d.temperature_2m_min[i]),
                slots: slotsFor(ymd)
            })
        }
        daily = days
        var hours = []
        var now = Date.now()
        for (var k = 0; k < root.slotHours.length; k++) {
            var sh = root.slotHours[k]
            var today = new Date()
            var ymd0 = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2)
                + "-" + ("0" + today.getDate()).slice(-2)
            var hit0 = byKey[ymd0 + "-" + sh]
            if (!hit0)
                continue
            if (hit0.at.getTime() + 30 * 60 * 1000 < now)
                continue
            hours.push({
                label: (sh < 10 ? "0" : "") + sh,
                icon: hit0.icon,
                temp: hit0.temp
            })
        }
        if (hours.length < 4 && days.length > 1) {
            var extra = days[1].slots
            for (var e = 0; e < extra.length && hours.length < 6; e++) {
                hours.push({
                    label: extra[e].label,
                    icon: extra[e].icon,
                    temp: extra[e].temp
                })
            }
        }
        hourly = hours
        todaySlots = hours
        hasData = true
        loading = false
        error = ""
    }

    Component.onCompleted: refresh()
    onSourceChanged: refresh()
    onLatitudeChanged: if (_isOm()) refresh()
    onLongitudeChanged: if (_isOm()) refresh()
    onTemperatureUnitChanged: refresh()
}
            })
        }
        daily = days
        hasData = true
        loading = false
        error = ""
    }

    Component.onCompleted: refresh()
    onSourceChanged: refresh()
    onTemperatureUnitChanged: refresh()
}
