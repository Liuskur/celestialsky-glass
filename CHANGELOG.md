# Changelog — Koollook Widgets

## 2.0.0

- Monorepo: Celestial Sky, Calendar, and Weather in one repo
- Shared QML module `org.koollook.glass` plus common Appearance config
- Rebrand to Koollook; plugin IDs `com.koollook.celestialsky`, `com.koollook.calendar`, `com.koollook.weather`
- `scripts/package.sh` and GitHub Actions build all three widgets at once

## Celestial Sky 1.4.0

- Appearance settings match Calendar/Weather (Copy/Paste style, glass/solid, tint %, blur, refraction…)
- Sky tab: Weather-style location search + lat/lon; planet size
- LiquidGlass wired to the same configuration keys as the other widgets

## 1.3.9
- Time scrubber: hover + wheel/touchpad scroll only (no drag)
- Click scrubber to reset to present; default mouse cursor on hover

## 1.3.8
- All bodies hide during their night cycle
- Tabloids always visible; night shows last set (blue) then next rise (orange)
- Equal tabloid gaps (ideal 5px, shrink evenly); left/right margins; no right overflow

## 1.3.7
- Planets hide at night like Sun/Moon
- Tabloids always shown with day/night time order

## 1.3.6
- Sun/Moon fully leave the sky at night (no stuck-at-set)

## 1.3.5
- Sun colour grade: red/dark at rise & set, bright yellow at zenith

## 1.3.4
- Sun peak height: top edge touches widget top border at noon
- Zenith brightness boost

## 1.3.3
- Fixed Jupiter half-disk clipping; new sun without white halo
- Draw large→small

## 1.3.2
- Moon −30% size; sun max arc / moon mid / planets lower
- Scrubber: block press-and-hold edit mode

## 1.3.1
- Time scrubber drives clock, positions, tabloid times
- Block desktop drag outside edit mode

## 1.3.0
- Glass time scrubber ±72 h
- 3D body icons; planet sizes

## 1.2.x
- Continuous glass under tabloids; arc fill; tabloid 50% tint
