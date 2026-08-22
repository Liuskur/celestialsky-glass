# Changelog — Koollook Widgets

## 0.7.3

- Suite **0.7.3**
- **Koollook Light** color scheme + global theme (one Plasma style; Dark remains default)
- Koollook Dotted follows system WM colors; dots = Common Colors Tooltip Background
- Aqua: Rachel Alucard / observer (cream, crimson, gold, gothic burgundy)
- Eesti: white body, classy gray text, xenon-blue stripes, black wheels/chrome
- Liwi: white buttons; white symbolic griffin
- Light griffin + wallpaper `Koollook-Light`
- Plasma style **Koollook** (Stone layout)
- LICENSE recast: MIT default; Willow title-bar GPL-3.0-only; Aurorae QML GPL-2.0-or-later; Plasma style LGPL-2.1-or-later

## 0.7.2

- Suite **0.7.2**

## 0.7.1

- Suite **0.7.1**: per-piece tarballs + bundle; title-bar pack renamed `koollook-titlebar`
- User-facing Aurorae wording is KoollooK / title bar (KWin Aurorae engine kept)
- Plasma splash wordmark **KoollooK**
## 0.7.0

- Unified version **0.7.0** across widgets, theme, decorations, wallpapers, look-and-feel, SDDM
- First numbered Koollook suite release (replaces mixed 1.x / 2.x / 2.8.0 labels)
- Release assets: one tarball per piece, plus suite bundle `koollook-0.7.0.tar.zst`
- Plasma splash wordmark: **KoollooK**
- User-facing “Aurorae” renamed to KoollooK / title bar; KWin Aurorae engine paths and IDs unchanged
## 2.8.0

- **Koollook Muhurta** (`com.koollook.muhurta`): Vedic 30 named muhūrtas from local sunrise
- **Koollook Hora** (`com.koollook.hora`): planetary hours, 12 day + 12 night, Chaldean order
- Shared engine `shared/timekeeping/koollook-time.js` drives both Plasma widgets and standalone sites `web/muhurta/`, `web/hora/`

## 2.7.0

- Sky widget renamed **Koollook Planisphere** (`com.koollook.planisphere`)
## 2.6.0

- System tray applet `com.koollook.stt`: start/stop listening, send/delete clip, audio sources

## 2.3.0

- Shared `KoollookFrame`: Glass, Solid, Clear (see-through), Plasma, Chameleon, Inverse, Koollook
- Invisible frame option; Inverse uses opposite of desktop background for text/icons
- KDE 2 window decoration ported to Plasma 6 KDecoration3
- Packs: `koollook-theme`, `koollook-widgets`, `koollook-accessibility`
- Renamed `MacOSColors` → `KoollookColors`

## 2.2.0

- STT clip widget `com.koollook.sttclip`: live local transcription buffer
- Spoken **delete clip** clears the buffer; **send clip** types/copies it
- Release archive: all plasmoids + theme + STT (`./scripts/package.sh`)

## 2.0.0

- Monorepo: Celestial Sky, Calendar, and Weather in one repo
- Shared QML modules `org.koollook.glass` and `org.koollook.location`
- Calendar is original MIT code using Plasma `MonthView` (Digital Clock popup)
- Weather is original MIT code, Weather Report layout, Open-Meteo
- Removed GPL macOS-widget sources
- Rebrand to Koollook; plugin IDs `com.koollook.*`
- Theme: Koollook color scheme, title bar, look-and-feel, KWin effects (from RiderLook)
- Accessibility STT via ResoNider whisper.cpp; KDE Connect runcommand + Pulse source hook
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
