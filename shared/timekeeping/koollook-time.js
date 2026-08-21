// Koollook timekeeping — sunrise, Vedic muhurta, planetary hora.
// Load in a browser or QML: import "koollook-time.js" as KT
// MIT

function _r(d) { return d * Math.PI / 180 }
function _d(r) { return r * 180 / Math.PI }

function toJulian(date) {
    return date.getTime() / 86400000 + 2440587.5
}

function fromJulian(j) {
    return new Date((j - 2440587.5) * 86400000)
}

function solarDeclination(n) {
    var g = _r(357.52911 + 0.98560028 * n)
    var q = _r(280.46646 + 0.98564736 * n)
    var L = q + _r(1.9148 * Math.sin(g) + 0.02 * Math.sin(2 * g))
    var e = _r(23.439291 - 0.00000036 * n)
    return Math.asin(Math.sin(e) * Math.sin(L))
}

function equationOfTime(n) {
    var g = _r(357.52911 + 0.98560028 * n)
    var q = _r(280.46646 + 0.98564736 * n)
    var e = 0.016708634
    var y = Math.tan(_r(23.4393) / 2)
    y = y * y
    var E = y * Math.sin(2 * q) - 2 * e * Math.sin(g) + 4 * e * y * Math.sin(g) * Math.cos(2 * q)
        - 0.5 * y * y * Math.sin(4 * q) - 1.25 * e * e * Math.sin(2 * g)
    return _d(E) * 4
}

function _zenithHa(lat, dec, zenith) {
    var cosH = (Math.cos(_r(zenith)) - Math.sin(_r(lat)) * Math.sin(dec))
        / (Math.cos(_r(lat)) * Math.cos(dec))
    if (cosH > 1) return null
    if (cosH < -1) return null
    return _d(Math.acos(cosH))
}

function sunTimes(lat, lon, when) {
    var local = when ? new Date(when.getTime()) : new Date()
    var y = local.getFullYear()
    var mo = local.getMonth()
    var da = local.getDate()
    var noon = new Date(y, mo, da, 12, 0, 0, 0)
    var n = toJulian(noon) - 2451545.0
    var dec = solarDeclination(n)
    var eq = equationOfTime(n)
    var ha = _zenithHa(lat, dec, 90.833)
    var solarNoonMin = 720 - 4 * lon - eq
    var tzOff = -noon.getTimezoneOffset()
    function atMin(mins) {
        var x = new Date(y, mo, da, 0, 0, 0, 0)
        x.setTime(x.getTime() + (mins + tzOff) * 60000)
        return x
    }
    var sunrise, sunset
    if (ha === null) {
        sunrise = new Date(y, mo, da, 0, 0, 0, 0)
        sunset = new Date(y, mo, da, 23, 59, 59, 0)
        if (lat > 0 && dec > 0) sunset = new Date(sunrise.getTime() + 86400000 - 1000)
        if (lat < 0 && dec < 0) sunset = new Date(sunrise.getTime() + 86400000 - 1000)
    } else {
        sunrise = atMin(solarNoonMin - 4 * ha)
        sunset = atMin(solarNoonMin + 4 * ha)
    }
    var next = new Date(y, mo, da + 1, 12, 0, 0, 0)
    var prev = new Date(y, mo, da - 1, 12, 0, 0, 0)
    var nxt = sunTimesNoon(lat, lon, next)
    var prv = sunTimesNoon(lat, lon, prev)
    return {
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: nxt.sunrise,
        prevSunrise: prv.sunrise,
        prevSunset: prv.sunset,
        solarNoon: atMin(solarNoonMin)
    }
}

function sunTimesNoon(lat, lon, noon) {
    var y = noon.getFullYear(), mo = noon.getMonth(), da = noon.getDate()
    var n = toJulian(noon) - 2451545.0
    var dec = solarDeclination(n)
    var eq = equationOfTime(n)
    var ha = _zenithHa(lat, dec, 90.833)
    var solarNoonMin = 720 - 4 * lon - eq
    var tzOff = -noon.getTimezoneOffset()
    function atMin(mins) {
        var x = new Date(y, mo, da, 0, 0, 0, 0)
        x.setTime(x.getTime() + (mins + tzOff) * 60000)
        return x
    }
    if (ha === null) {
        var sr = new Date(y, mo, da, 0, 0, 0, 0)
        var ss = new Date(y, mo, da, 23, 59, 59, 0)
        return { sunrise: sr, sunset: ss }
    }
    return { sunrise: atMin(solarNoonMin - 4 * ha), sunset: atMin(solarNoonMin + 4 * ha) }
}

function solarWindow(lat, lon, now) {
    var t = sunTimes(lat, lon, now)
    if (now.getTime() < t.sunrise.getTime()) {
        return {
            sunrise: t.prevSunrise,
            sunset: t.prevSunset,
            nextSunrise: t.sunrise,
            weekday: t.prevSunrise.getDay()
        }
    }
    return {
        sunrise: t.sunrise,
        sunset: t.sunset,
        nextSunrise: t.nextSunrise,
        weekday: t.sunrise.getDay()
    }
}

function fmtHM(date) {
    var h = date.getHours(), m = date.getMinutes()
    return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m
}

var MUHURTA = [
    { name: "Rudra", meaning: "Howler", quality: "inauspicious" },
    { name: "Ahi", meaning: "Serpent", quality: "inauspicious" },
    { name: "Mitra", meaning: "Friend", quality: "auspicious" },
    { name: "Pitri", meaning: "Ancestors", quality: "inauspicious" },
    { name: "Vasu", meaning: "Bright", quality: "auspicious" },
    { name: "Varaha", meaning: "Boar", quality: "auspicious" },
    { name: "Vishvedeva", meaning: "All-gods", quality: "auspicious" },
    { name: "Vidhi", meaning: "Rule", quality: "auspicious" },
    { name: "Sutamukhi", meaning: "Nectar-face", quality: "auspicious" },
    { name: "Puruhuta", meaning: "Indra", quality: "auspicious" },
    { name: "Vahini", meaning: "Army", quality: "inauspicious" },
    { name: "Naktanakara", meaning: "Night-maker", quality: "inauspicious" },
    { name: "Varuna", meaning: "Waters", quality: "auspicious" },
    { name: "Aryaman", meaning: "Companion", quality: "auspicious" },
    { name: "Bhaga", meaning: "Fortune", quality: "auspicious" },
    { name: "Girisha", meaning: "Lord of mountains", quality: "inauspicious" },
    { name: "Ajapada", meaning: "Goat-foot", quality: "inauspicious" },
    { name: "Ahirbudhnya", meaning: "Serpent of the deep", quality: "auspicious" },
    { name: "Pushya", meaning: "Nourisher", quality: "auspicious" },
    { name: "Ashvini", meaning: "Horsemen", quality: "auspicious" },
    { name: "Yama", meaning: "Restrainer", quality: "inauspicious" },
    { name: "Agni", meaning: "Fire", quality: "auspicious" },
    { name: "Vidhatri", meaning: "Arranger", quality: "auspicious" },
    { name: "Kanda", meaning: "Stem", quality: "auspicious" },
    { name: "Aditi", meaning: "Boundless", quality: "auspicious" },
    { name: "Jiva", meaning: "Life / Amrita", quality: "auspicious" },
    { name: "Vishnu", meaning: "Preserver", quality: "auspicious" },
    { name: "Dyumadgadyuti", meaning: "Resplendent", quality: "auspicious" },
    { name: "Brahma", meaning: "Creator", quality: "auspicious" },
    { name: "Samudram", meaning: "Ocean", quality: "auspicious" }
]

function muhurtaSchedule(lat, lon, now) {
    var w = solarWindow(lat, lon, now)
    var dayLen = w.sunset.getTime() - w.sunrise.getTime()
    var nightLen = w.nextSunrise.getTime() - w.sunset.getTime()
    if (dayLen < 60000) dayLen = 43200000
    if (nightLen < 60000) nightLen = 43200000
    var daySlot = dayLen / 15
    var nightSlot = nightLen / 15
    var periods = []
    var i, start, end, meta
    for (i = 0; i < 15; i++) {
        start = new Date(w.sunrise.getTime() + i * daySlot)
        end = new Date(w.sunrise.getTime() + (i + 1) * daySlot)
        meta = MUHURTA[i]
        periods.push({
            index: i + 1, name: meta.name, meaning: meta.meaning, quality: meta.quality,
            start: start, end: end, label: fmtHM(start) + "–" + fmtHM(end), daypart: "day"
        })
    }
    for (i = 0; i < 15; i++) {
        start = new Date(w.sunset.getTime() + i * nightSlot)
        end = new Date(w.sunset.getTime() + (i + 1) * nightSlot)
        meta = MUHURTA[15 + i]
        periods.push({
            index: 16 + i, name: meta.name, meaning: meta.meaning, quality: meta.quality,
            start: start, end: end, label: fmtHM(start) + "–" + fmtHM(end), daypart: "night"
        })
    }
    return {
        kind: "muhurta", window: w, periods: periods, current: currentPeriod(periods, now),
        sunriseLabel: fmtHM(w.sunrise), sunsetLabel: fmtHM(w.sunset)
    }
}

var CHALDEAN = ["saturn", "jupiter", "mars", "sun", "venus", "mercury", "moon"]
var DAY_LORD = ["sun", "moon", "mars", "mercury", "jupiter", "venus", "saturn"]
var HORA_INFO = {
    sun: { name: "Sun", quality: "authority, leadership", tone: "vigorous" },
    moon: { name: "Moon", quality: "home, travel, feeling", tone: "gentle" },
    mars: { name: "Mars", quality: "effort, conflict, body", tone: "fierce" },
    mercury: { name: "Mercury", quality: "speech, trade, skill", tone: "quick" },
    jupiter: { name: "Jupiter", quality: "learning, blessing, wealth", tone: "fruitful" },
    venus: { name: "Venus", quality: "art, union, pleasure", tone: "beneficial" },
    saturn: { name: "Saturn", quality: "labour, delay, endurance", tone: "heavy" }
}

function horaSchedule(lat, lon, now) {
    var w = solarWindow(lat, lon, now)
    var dayLen = w.sunset.getTime() - w.sunrise.getTime()
    var nightLen = w.nextSunrise.getTime() - w.sunset.getTime()
    if (dayLen < 60000) dayLen = 43200000
    if (nightLen < 60000) nightLen = 43200000
    var daySlot = dayLen / 12
    var nightSlot = nightLen / 12
    var lord = DAY_LORD[w.weekday]
    var idx = CHALDEAN.indexOf(lord)
    if (idx < 0) idx = 0
    var periods = []
    var i, start, end, id, info
    for (i = 0; i < 12; i++) {
        start = new Date(w.sunrise.getTime() + i * daySlot)
        end = new Date(w.sunrise.getTime() + (i + 1) * daySlot)
        id = CHALDEAN[(idx + i) % 7]
        info = HORA_INFO[id]
        periods.push({
            index: i + 1, planet: id, name: info.name, meaning: info.quality, quality: info.tone,
            start: start, end: end, label: fmtHM(start) + "–" + fmtHM(end), daypart: "day"
        })
    }
    for (i = 0; i < 12; i++) {
        start = new Date(w.sunset.getTime() + i * nightSlot)
        end = new Date(w.sunset.getTime() + (i + 1) * nightSlot)
        id = CHALDEAN[(idx + 12 + i) % 7]
        info = HORA_INFO[id]
        periods.push({
            index: 13 + i, planet: id, name: info.name, meaning: info.quality, quality: info.tone,
    return {
        kind: "hora", window: w, periods: periods, current: currentPeriod(periods, now),
        dayLord: HORA_INFO[lord].name,
        sunriseLabel: fmtHM(w.sunrise), sunsetLabel: fmtHM(w.sunset)
    }
        dayLord: HORA_INFO[lord].name
    }
}

function currentPeriod(periods, now) {
    var t = now.getTime()
    var i
    for (i = 0; i < periods.length; i++) {
        if (t >= periods[i].start.getTime() && t < periods[i].end.getTime())
            return periods[i]
    }
    return periods[periods.length - 1]
}

function progress(period, now) {
    if (!period) return 0
    var a = period.start.getTime(), b = period.end.getTime(), t = now.getTime()
    if (b <= a) return 0
    var p = (t - a) / (b - a)
    if (p < 0) return 0
    if (p > 1) return 1
var KoollookTime = {
    sunTimes: sunTimes,
    solarWindow: solarWindow,
    muhurtaSchedule: muhurtaSchedule,
    horaSchedule: horaSchedule,
    currentPeriod: currentPeriod,
    progress: progress,
    fmtHM: fmtHM
}

if (typeof window !== "undefined")
    window.KoollookTime = KoollookTime
if (typeof module !== "undefined" && module.exports)
    module.exports = KoollookTime
        fmtHM: fmtHM
    }
}
