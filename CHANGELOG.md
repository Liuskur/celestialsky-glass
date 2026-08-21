# Changelog — Koollook Widgets

## 2.5.0

- Livonian-style griffin icon theme (`Koollook`): regular launcher, white, charcoal, symbolic
- Color schemes: Koollook Dark, Aqua (light), Eesti, Livonia

## 2.4.0

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
- Theme: Koollook color scheme, Aurorae decoration, look-and-feel, KWin effects (from RiderLook)
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
