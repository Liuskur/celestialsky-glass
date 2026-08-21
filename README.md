# Koollook

Plasma 6 widgets, theme, and local accessibility STT. Former Celestial Sky (Glass) repository.

## Widgets

| Widget | Plugin ID | Version |
|--------|-----------|---------|
| Koollook Planisphere | `com.koollook.planisphere` | 0.7.2 |
| Koollook Calendar | `com.koollook.calendar` | 0.7.2 |
| Koollook Weather | `com.koollook.weather` | 0.7.2 |
| Koollook Muhurta | `com.koollook.muhurta` | 0.7.2 |
| Koollook Hora | `com.koollook.hora` | 0.7.2 |
| Koollook STT Clip | `com.koollook.sttclip` | 0.7.2 |
| Koollook STT | `com.koollook.stt` | 0.7.2 |
| Koollook Wavebar | `com.koollook.audioviz` | 0.7.2 |
`shared/glass` is QML module `org.koollook.glass`. `shared/location` is `org.koollook.location`.
`shared/appearance/ConfigAppearance.qml` is the common Appearance page.
`shared/timekeeping/koollook-time.js` is the Muhurta/Hora engine (browser + QML).
`scripts/sync-shared.sh` vendors those files into each plasmoid so Store packages stay self-contained.
## Package

```bash
./scripts/package.sh
```
Writes `dist/`:

- KDE Store: `com.koollook.*.plasmoid`
- One tarball per piece (download only what you want):
  - `koollook-colors-0.7.2.tar.zst`
  - `koollook-icons-0.7.2.tar.zst`
  - `koollook-titlebar-0.7.2.tar.zst` (KoollooK title bar)
  - `koollook-dotted-0.7.2.tar.zst` (Koollook Dotted)
  - `koollook-splash-0.7.2.tar.zst` (Plasma splash, wordmark **KoollooK**)
  - `koollook-sddm-0.7.2.tar.zst`
  - `koollook-plymouth-0.7.2.tar.zst`
  - `koollook-wallpaper-0.7.2.tar.zst` plus `koollook-wallpaper-1` … `7`
  - `koollook-accessibility-0.7.2.tar.zst`
- Full bundle: `koollook-0.7.2.tar.zst` (every piece + `install.sh`)

```bash
./scripts/install.sh
# or, from a downloaded bundle / piece dir:
# ./install.sh --help
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.planisphere-0.7.2.plasmoid
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.calendar-0.7.2.plasmoid
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.weather-0.7.2.plasmoid
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.muhurta-0.7.2.plasmoid
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.hora-0.7.2.plasmoid
```

Then: Desktop → Add Widgets → search “Koollook”. Standalone sites: open `web/muhurta/index.html` or `web/hora/index.html`.

## Layout

```
theme/                         KoollooK colors, title bar, look-and-feel, KWin
accessibility/koollook-stt/    local English dictation (whisper.cpp)
shared/glass/                  org.koollook.glass
shared/location/               org.koollook.location
shared/appearance/             ConfigAppearance.qml
shared/timekeeping/            sunrise, muhurta, hora (JS + TimeBoard)
web/muhurta/  web/hora/        standalone Koollook SPAs (open index.html)
plasmoids/com.koollook.*/      widget-specific sources
scripts/package.sh             per-piece tarballs + suite bundle
```

## Theme

```bash
./theme/install.sh
```

Color schemes: **Koollook Dark**, **Aqua**, **Eesti**, **Liwi**. Window decorations: **Koollook** and **Koollook Dotted**. See `theme/README.md`, `TESTERS.md`, `PUBLISH.md`.
## Accessibility STT

Local English speech-to-text into a clip buffer. Tray applet **Koollook STT** start/stop; clip widget shows the buffer.
Say **delete clip** to empty the buffer. Say **send clip** to type it into the focused field.

```bash
./accessibility/koollook-stt/install.sh
koollook-stt --toggle
```

Phone: KDE Connect Run Command (toggle/start/stop). `KOOLLOOK_STT_SOURCE=auto` uses a `kdeconnect` Pulse source when the phone is a mic.

Tray: after install, **Koollook STT** is in the system tray (Panel → System Tray Settings → Entries if hidden). Middle-click toggles listening.

- KDE Plasma 6

## License

MIT for widgets and QML. Title-bar SVGs (Willow) are GPL-3.0. See `LICENSE` and `theme/README.md`.

## Changelog

See `CHANGELOG.md`.
