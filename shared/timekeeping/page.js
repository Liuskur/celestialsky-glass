(function () {
  function $(id) { return document.getElementById(id) }
  function pad(n) { return n < 10 ? "0" + n : "" + n }

  window.KoollookTimePage = {
    start: function (opts) {
      var latEl = $("lat"), lonEl = $("lon")
      var title = document.title
      function loc() {
        return {
          lat: parseFloat(latEl.value) || 59.437,
          lon: parseFloat(lonEl.value) || 24.754
        }
      }
      function paint() {
        var L = loc()
        var now = new Date()
        var day = opts.kind === "hora"
          ? window.KoollookTime.horaSchedule(L.lat, L.lon, now)
          : window.KoollookTime.muhurtaSchedule(L.lat, L.lon, now)
        var cur = day.current
        $("now-name").textContent = cur ? cur.name : "—"
        $("now-meta").textContent = cur
          ? cur.meaning + " · " + cur.quality + " · " + cur.label
          : ""
        var p = window.KoollookTime.progress(cur, now)
        $("bar").style.width = Math.round(p * 100) + "%"
        $("sun").textContent = "Sunrise " + window.KoollookTime.fmtHM(day.window.sunrise)
          + " · Sunset " + window.KoollookTime.fmtHM(day.window.sunset)
          + (day.dayLord ? " · Day lord " + day.dayLord : "")
        var tb = $("rows")
        tb.innerHTML = ""
          var tr = document.createElement("tr")
          var cls = x.daypart || ""
          if (cur && x.index === cur.index) cls += (cls ? " " : "") + "current"
          tr.className = cls
          var qclass = (x.quality === "inauspicious" || x.quality === "fierce" || x.quality === "heavy") ? "bad" : "ok"
          tr.innerHTML = "<td>" + x.index + "</td><td>" + x.name + "</td><td class='" + qclass + "'>"
            + x.quality + "</td><td>" + x.label + "</td>"
          tb.appendChild(tr)
      }
      $("geo").onclick = function () {
        if (!navigator.geolocation) return
        navigator.geolocation.getCurrentPosition(function (pos) {
          latEl.value = pos.coords.latitude.toFixed(4)
          lonEl.value = pos.coords.longitude.toFixed(4)
          paint()
        })
      }
      latEl.onchange = lonEl.onchange = paint
      $("go").onclick = paint
      paint()
      setInterval(paint, 15000)
      document.title = title
    }
  }
})()
