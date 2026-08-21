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
        connectedSources: root.source && root.source.length ? [root.source] : []
        onNewData: function (sourceName, data) {
            if (sourceName !== root.source)
                return
            root._applyEngine(data)
        }
    }

    function refresh() {
        if (!source || !source.length) {
            error = i18n("Pick a weather station")
            return
        }
        loading = true
        error = ""
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
            if (!root.hasData && root.source.indexOf("bbcukmet|") === 0)
                root._fetchBbc()
            else if (!root.hasData)
                root.loading = false
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
                name: Qt.locale().dayName(dt.getDay(), Locale.ShortFormat),
                ymd: ymd,
                icon: _bbcIcon(srep.weatherType),
                high: formatTemp(srep.maxTempC),
                low: formatTemp(srep.minTempC),
                slots: slots
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
