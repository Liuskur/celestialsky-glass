# Koollook Muhurta and Hora

Shared engine: `koollook-time.js` (browser, Node, QML). UI: `TimeBoard.qml`, `ConfigLocation.qml`, `koollook.css`, `page.js`.

- **Muhurta** — Vedic civil day of **30** named muhūrtas. Sunrise→sunset is 15 equal parts; sunset→next sunrise is 15. Each is ~48 minutes only near equinox.
- **Hora** — planetary hours: **12** daytime + **12** night, unequal except at equinox. First hora after sunrise is the weekday planet; then the Chaldean order Saturn, Jupiter, Mars, Sun, Venus, Mercury, Moon.

`scripts/sync-shared.sh` vendors the engine into `plasmoids/com.koollook.muhurta` and `…/hora`, and copies CSS/JS into `web/muhurta/` and `web/hora/` (open `index.html`; no build step).
