# Koollook

Plasma 6 widgets, theme, and local accessibility STT. Former Celestial Sky (Glass) repository.

## Widgets

| Widget | Plugin ID | Version |
|--------|-----------|---------|
| Koollook Celestial Sky | `com.koollook.celestialsky` | 1.4.0 |
| Koollook Calendar | `com.koollook.calendar` | 2.0.0 |
| Koollook Weather | `com.koollook.weather` | 2.0.0 |
| Koollook STT Clip | `com.koollook.sttclip` | 1.0.0 |
| Koollook STT | `com.koollook.stt` | 1.0.0 |
| Koollook Wavebar | `com.koollook.audioviz` | 1.0.0 |
`shared/glass` is QML module `org.koollook.glass`. `shared/location` is `org.koollook.location`.
`shared/appearance/ConfigAppearance.qml` is the common Appearance page.
`scripts/sync-shared.sh` vendors those files into each plasmoid so Store packages stay self-contained.

## Package all widgets

```bash
./scripts/package.sh
```
Writes `dist/`:

- KDE Store: `com.koollook.*.plasmoid`
- Theme pack: `koollook-theme-2.3.0.tar.zst`
- Widgets pack: `koollook-widgets-2.3.0.tar.zst`
- Accessibility pack: `koollook-accessibility-2.3.0.tar.zst`
- Full: `koollook-2.3.0.tar.zst`

```bash
./scripts/install.sh
# or:
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.celestialsky-1.4.0.plasmoid
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.celestialsky-1.4.0.plasmoid
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.calendar-2.0.0.plasmoid
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.weather-2.0.0.plasmoid

Then: Desktop → Add Widgets → search “Koollook”.

## Layout

```
theme/                         Koollook colors, Aurorae, look-and-feel, KWin
accessibility/koollook-stt/    local English dictation (whisper.cpp)
shared/glass/                  org.koollook.glass
shared/location/               org.koollook.location
shared/appearance/             ConfigAppearance.qml
plasmoids/com.koollook.*/      widget-specific sources
scripts/package.sh             builds all three
```

## Theme

```bash
./theme/install.sh
```

Color scheme **Koollook**, window decoration **Koollook**, KWin translucency + hide-cursor. See `theme/README.md`.

## Accessibility STT

Local English speech-to-text into the focused field. Reuses ResoNider whisper.cpp. Phone can start/stop via KDE Connect Run Command; audio source `auto` uses a `kdeconnect` Pulse source when present.

```bash
Local English speech-to-text into a **clip buffer** shown by the STT Clip widget.
Say **delete clip** to empty the buffer. Say **send clip** to type/copy it (actualize).

```bash
./accessibility/koollook-stt/install.sh
koollook-stt --toggle
```

Phone: KDE Connect Run Command (toggle/start/stop). `KOOLLOOK_STT_SOURCE=auto` uses a `kdeconnect` Pulse source when the phone is a mic.
- KDE Plasma 6
- Desktop containment (not panel)

## License

MIT for widgets and QML. Aurorae decoration SVGs are GPL-3.0 (Willow). See `LICENSE` and `theme/README.md`.

## Changelog

See `CHANGELOG.md`.
