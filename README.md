# Celestial Sky (Glass) — `com.riderlook.celestialsky` v1.3.8

Plasma **6** desktop widget: planetary sky with liquid-glass frame (RiderLook).

## Features
- Sun, Moon, planets on rise–set arcs (astronomy.js)
- Live rise/set tabloids (50% glass tint cards)
- Continuous liquid-glass (no bottom band)
- Time scrubber −72…+72 h (1 h steps); clock + positions + times update live
- Sun: red/dark at rise-set, bright yellow at zenith; hidden at night
- Moon mid-arc between sun and planets; night hide
- Photoreal body icons

## Install
```bash
kpackagetool6 -t Plasma/Applet -i com.riderlook.celestialsky-1.3.8.plasmoid
# upgrade:
kpackagetool6 -t Plasma/Applet -u com.riderlook.celestialsky-1.3.8.plasmoid
```
Then: Desktop → Add Widgets → “Celestial Sky (Glass)”.

## Configure
Right-click widget → Configure: latitude/longitude, planet scale, glass tint/blur/radius.

## Requirements
- KDE Plasma 6
- Desktop containment (not panel)

## License
MIT — see LICENSE

## Changelog
See CHANGELOG.md
