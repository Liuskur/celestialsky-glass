# Koollook Widgets

Plasma 6 desktop widgets with a shared liquid-glass QML module.

This is the former Celestial Sky (Glass) repository, now the Koollook widget suite.

## Widgets

| Widget | Plugin ID | Version |
|--------|-----------|---------|
| Koollook Celestial Sky | `com.koollook.celestialsky` | 1.4.0 |
| Koollook Calendar | `com.koollook.calendar` | 1.1.0 |
| Koollook Weather | `com.koollook.weather` | 1.1.0 |

## Shared component

`shared/glass` is QML module `org.koollook.glass` (`LiquidGlass`, `MacOSColors`, shaders).
`shared/appearance/ConfigAppearance.qml` is the common Appearance page.

`scripts/sync-shared.sh` vendors those files into each plasmoid so KDE Store packages stay self-contained.

## Package all widgets

```bash
./scripts/package.sh
```

Writes `dist/`:

- `com.koollook.celestialsky-1.4.0.plasmoid`
- `com.koollook.calendar-1.1.0.plasmoid`
- `com.koollook.weather-1.1.0.plasmoid`
- `koollook-widgets-2.0.0.tar.zst`
- `SHA256SUMS`

GitHub Actions on `main` and `v*` tags produce the same artifacts.

## Install

```bash
./scripts/install.sh
# or:
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.celestialsky-1.4.0.plasmoid
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.calendar-1.1.0.plasmoid
kpackagetool6 -t Plasma/Applet -i dist/com.koollook.weather-1.1.0.plasmoid
```

Then: Desktop → Add Widgets → search “Koollook”.

## Layout

```
shared/glass/                  org.koollook.glass (canonical)
shared/appearance/             ConfigAppearance.qml
plasmoids/com.koollook.*/      widget-specific sources
scripts/package.sh             builds all three
```

## Migrating from older IDs

| Old | New |
|-----|-----|
| `com.riderlook.celestialsky` | `com.koollook.celestialsky` |
| `com.jaxparrow07.macoswidgets.calendar` | `com.koollook.calendar` |
| `com.jaxparrow07.macoswidgets.weather` | `com.koollook.weather` |

Remove the old applet, then add the Koollook one. Configuration is not migrated.

## Requirements

- KDE Plasma 6
- Desktop containment (not panel)

## License

See `LICENSE`. Calendar, Weather, and the glass module are GPL-3.0. Celestial Sky widget-specific sources are MIT; the packaged celestial-sky plasmoid includes GPL glass and is GPL-3.0-only.

## Changelog

See `CHANGELOG.md`.
