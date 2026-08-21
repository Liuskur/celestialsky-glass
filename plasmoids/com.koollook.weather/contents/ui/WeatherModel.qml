// SPDX-License-Identifier: MIT
// BBC Weather (same ion as Plasma Weather Report). Optional: NOAA, DWD, wetter.com, EnvCan, Open-Meteo.
import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

QtObject {
    id: root

    property string source: "bbcukmet|weather|Tallinn, Estonia, EE|588409"
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
    readonly property var slotHours: [0, 3, 6, 9, 12, 15, 18, 21]
    property int _reqId: 0

    function _isOm() {
        return source === "openmeteo" || source.indexOf("openmeteo|") === 0
    }

    function _isBbc() {
        return source.indexOf("bbcukmet|") === 0
    }

    property var engine: Plasma5Support.DataSource {
        engine: "weather"
        interval: 30 * 60 * 1000
        connectedSources: {
            if (root._isOm() || root._isBbc())
                return []
            return root.source.length ? [root.source] : []
        }
        onNewData: function (sourceName, data) {
            if (sourceName !== root.source)
                return
            root._applyEngine(data)
        }
    }

    property var fallbackTimer: Timer {
        interval: 4000
        repeat: false
        onTriggered: {
            if (root.hasData)
                return
            if (root._isBbc())
                root._fetchBbc()
            else
                root.loading = false
        }
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
        if (_isBbc()) {
            _fetchBbc()
            return
        }
        try {
            engine.disconnectSource(source)
            engine.removeSource(source)
            engine.connectSource(source)
        } catch (e) {
        }
        fallbackTimer.restart()
    }

    function formatTemp(celsius) {
        if (celsius === undefined || celsius === null || celsius === "")
            return "—"
        var n = Number(celsius)
        if (isNaN(n))
            return "—"
        var v = temperatureUnit === 1 ? (n * 9 / 5 + 32) : n
        return Math.round(v) + "°"
    }

    function windArrow() {
        if (windDirText.length)
            return windDirText
        var dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        return dirs[Math.round(windDir / 45) % 8]
    }

    function _dayName(dt) {
        var names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        var i = dt && !isNaN(dt.getTime()) ? dt.getDay() : 0
        return names[i]
    }

    function _hourIsNight(hh) {
        return hh < 6 || hh >= 21
    }

    function _slotMatch(hh) {
        var si
        for (si = 0; si < slotHours.length; si++) {
            if (slotHours[si] === hh)
                return true
        }
        return false
    }

    function _pad2(n) {
        return (n < 10 ? "0" : "") + n
    }

    function _ymdFromDate(dt) {
        return dt.getFullYear() + "-" + _pad2(dt.getMonth() + 1) + "-" + _pad2(dt.getDate())
    }

    function _todayYmd() {
        return _ymdFromDate(new Date())
    }

    function _shiftYmd(ymd, days) {
        var p = (ymd || "").split("-")
        if (p.length < 3)
            return ymd
        var dt = new Date(parseInt(p[0], 10), parseInt(p[1], 10) - 1, parseInt(p[2], 10) + days)
        return _ymdFromDate(dt)
    }

    function _bbcDay(forecasts, ymd) {
        var out = { sum: ({}), reports: [] }
        var d, srep, rep, r, hh, dest
        for (d = 0; d < forecasts.length; d++) {
            srep = (forecasts[d].summary && forecasts[d].summary.report) ? forecasts[d].summary.report : {}
            if (srep.localDate === ymd) {
                if (srep.maxTempC !== null && srep.maxTempC !== undefined)
                    out.sum = srep
                else if (!out.sum.localDate)
                    out.sum = srep
            }
            rep = (forecasts[d].detailed && forecasts[d].detailed.reports) ? forecasts[d].detailed.reports : []
            for (r = 0; r < rep.length; r++) {
                hh = parseInt((rep[r].timeslot || "99").split(":")[0], 10)
                dest = srep.localDate || ""
                if (hh < 6)
                    dest = _shiftYmd(dest, 1)
                if (dest === ymd)
                    out.reports.push(rep[r])
            }
        }
        return out
    }

    function _bbcSlotsFromReports(reports, fallbackType, onlyPresent) {
        var byHour = ({})
        var r, ts, hh
        for (r = 0; r < reports.length; r++) {
            ts = reports[r].timeslot || ""
            hh = parseInt(ts.split(":")[0], 10)
            if (hh >= 0 && hh <= 23)
                byHour[hh] = reports[r]
        }
        var slots = []
        var s, hour, hit
        for (s = 0; s < slotHours.length; s++) {
            hour = slotHours[s]
            hit = byHour[hour] || byHour[hour + 1] || byHour[hour - 1]
            if (onlyPresent && !hit)
                continue
            slots.push({
                hour: hour,
                label: (hour < 10 ? "0" : "") + hour,
                icon: hit ? _bbcIcon(hit.weatherType, _hourIsNight(hour)) : "weather-none-available",
                temp: hit ? formatTemp(hit.temperatureC) : "—"
            })
        }
        return slots
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

    function _icon(code, night) {
        if (code === 0) return night ? "weather-clear-night" : "weather-clear"
        if (code === 1) return night ? "weather-few-clouds-night" : "weather-few-clouds"
        if (code === 2) return night ? "weather-clouds-night" : "weather-clouds"
        if (code === 3) return night ? "weather-clouds-night" : "weather-clouds"
        if (code === 45 || code === 48) return "weather-fog"
        if (code >= 51 && code <= 57) return night ? "weather-showers-scattered-night" : "weather-showers-scattered"
        if (code === 66 || code === 67) return "weather-freezing-rain"
        if (code >= 61 && code <= 65) return night ? "weather-showers-night" : "weather-showers"
        if (code >= 71 && code <= 77) return "weather-snow-scattered"
        if (code >= 80 && code <= 82) return night ? "weather-showers-night" : "weather-showers"
        if (code === 85 || code === 86) return "weather-snow"
        if (code >= 95 && code <= 99) return night ? "weather-storm-night" : "weather-storm"
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
        for (i = 1; i < n && days.length < 7; i++) {
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

    function _bbcIcon(type, night) {
        var n = parseInt(type, 10)
        var dark = night === true
        if (n === 0 || n === 1) return dark ? "weather-clear-night" : "weather-clear"
        if (n === 2 || n === 3) return dark ? "weather-few-clouds-night" : "weather-few-clouds"
        if (n >= 4 && n <= 8) return dark ? "weather-clouds-night" : "weather-clouds"
        if (n === 9 || n === 10) return dark ? "weather-showers-scattered-night" : "weather-showers-scattered"
        if (n >= 11 && n <= 18) return dark ? "weather-showers-night" : "weather-showers"
        if (n >= 19 && n <= 22) return "weather-snow"
        if (n >= 23 && n <= 30) return dark ? "weather-storm-night" : "weather-storm"
        return "weather-none-available"
    }

    function _fetchBbc() {
        var parts = source.split("|")
        var id = parts[parts.length - 1]
        if (!id || !/^[0-9]+$/.test(id))
            return
        var reqId = ++_reqId
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            if (reqId !== root._reqId)
                return
            if (xhr.status !== 200) {
                if (!root.hasData) {
                    root.loading = false
                    root.error = i18n("Could not load forecast")
                }
                return
            }
            try {
                var txt = xhr.responseText
                if (!txt || !txt.length) {
                    if (!root.hasData) {
                        root.loading = false
                        root.error = i18n("Could not load forecast")
                    }
                    return
                }
                root._applyBbc(JSON.parse(txt))
            } catch (e) {
                if (root.conditionText.length) {
                    root.hasData = true
                    root.loading = false
                    root.error = ""
                } else if (!root.hasData) {
                    root.loading = false
                    root.error = i18n("Could not read forecast")
                }
            }
        }
        xhr.open("GET", "https://weather-broker-cdn.api.bbci.co.uk/en/forecast/aggregated/" + id)
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
        var tC = nowR.temperatureC
        if (tC === null || tC === undefined)
            tC = sum.maxTempC
        temperature = tC || 0
        feelsLike = nowR.feelsLikeTemperatureC != null ? nowR.feelsLikeTemperatureC : temperature
        humidity = nowR.humidity || 0
        pressure = nowR.pressure || 0
        var kph = nowR.windSpeedKph || sum.windSpeedKph || 0
        windSpeed = kph / 3.6
        windDirText = nowR.windDirectionAbbreviation || sum.windDirectionAbbreviation || ""
        conditionText = nowR.enhancedWeatherDescription || nowR.weatherTypeText
            || sum.enhancedWeatherDescription || sum.weatherTypeText || ""
        iconName = _bbcIcon(nowR.weatherType !== undefined ? nowR.weatherType : sum.weatherType, isNight)
        credit = "BBC Weather"
        var todayYmd = _todayYmd()
        var todayPack = _bbcDay(forecasts, todayYmd)
        var hours = _bbcSlotsFromReports(todayPack.reports, todayPack.sum.weatherType, true)
        hourly = hours
        todaySlots = hours
        var days = []
        var k, ymd, pack, dt, hi, lo
        for (k = 1; k <= 7; k++) {
            ymd = _shiftYmd(todayYmd, k)
            pack = _bbcDay(forecasts, ymd)
            dt = new Date(ymd + "T12:00:00")
            hi = pack.sum.maxTempC
            if (hi === null || hi === undefined)
                hi = pack.sum.mostLikelyHighTemperatureC
            lo = pack.sum.minTempC
            if (lo === null || lo === undefined)
                lo = pack.sum.mostLikelyLowTemperatureC
            days.push({
                name: _dayName(dt),
                ymd: ymd,
                icon: _bbcIcon(pack.sum.weatherType, false),
                high: formatTemp(hi),
                low: formatTemp(lo),
                slots: _bbcSlotsFromReports(pack.reports, pack.sum.weatherType)
            })
        }
        daily = days
        hasData = true
        loading = false
        error = ""
    }

    function _fetchOpenMeteo() {
        var reqId = ++_reqId
        var xhr = new XMLHttpRequest()
        var url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + latitude
            + "&longitude=" + longitude
            + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,pressure_msl,wind_speed_10m,wind_direction_10m,is_day"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum"
            + "&hourly=temperature_2m,weather_code,is_day"
            + "&forecast_days=8&timezone=auto"
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            if (reqId !== root._reqId)
                return
            if (xhr.status !== 200) {
                if (!root.hasData) {
                    root.loading = false
                    root.error = i18n("Could not load forecast")
                }
                return
            }
            try {
                root._applyOm(JSON.parse(xhr.responseText))
            } catch (e) {
                if (!root.hasData) {
                    root.loading = false
                    root.error = i18n("Could not read forecast")
                }
            }
        }
        xhr.open("GET", url)
        xhr.send()
    }

    function _omSlots(ymd, byKey) {
        var slots = []
        var s, hour, hit
        for (s = 0; s < slotHours.length; s++) {
            hour = slotHours[s]
            hit = byKey[ymd + "-" + hour]
            slots.push({
                hour: hour,
                label: (hour < 10 ? "0" : "") + hour,
                icon: hit ? hit.icon : "weather-none-available",
                temp: hit ? hit.temp : "—"
            })
        }
        return slots
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
        var dly = resp.daily || {}
        var times = dly.time || []
        var h = resp.hourly || {}
        var ht = h.time || []
        var byKey = ({})
        var j, hd, key
        for (j = 0; j < ht.length; j++) {
            hd = new Date(ht[j])
            key = hd.getFullYear() + "-" + ("0" + (hd.getMonth() + 1)).slice(-2)
                + "-" + ("0" + hd.getDate()).slice(-2) + "-" + hd.getHours()
            byKey[key] = {
                icon: _icon(h.weather_code[j], h.is_day[j] === 0),
                temp: formatTemp(h.temperature_2m[j]),
                at: hd
            }
        }
        var ymd0 = _todayYmd()
        var days = []
        var i, dt, ymd, noon
        for (i = 0; i < times.length && days.length < 7; i++) {
            ymd = times[i]
            if (ymd === ymd0)
                continue
            dt = new Date(ymd + "T12:00:00")
            noon = byKey[ymd + "-12"] || byKey[ymd + "-15"]
            days.push({
                name: _dayName(dt),
                ymd: ymd,
                icon: noon ? noon.icon : _icon(dly.weather_code[i], false),
                high: formatTemp(dly.temperature_2m_max[i]),
                low: formatTemp(dly.temperature_2m_min[i]),
                slots: _omSlots(ymd, byKey)
            })
        }
        daily = days
        hourly = _omSlots(ymd0, byKey)
        todaySlots = hourly
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
