# Koollook Widgets

Plasma 6 desktop widgets with a shared liquid-glass QML module.

This is the former Celestial Sky (Glass) repository, now the Koollook widget suite.

## Widgets

| Widget | Plugin ID | Version |
|--------|-----------|---------|
| Koollook Celestial Sky | `com.koollook.celestialsky` | 1.4.0 |
| Koollook Calendar | `com.koollook.calendar` | 2.0.0 |
| Koollook Weather | `com.koollook.weather` | 2.0.0 |

`shared/glass` is QML module `org.koollook.glass`. `shared/location` is `org.koollook.location`.
`shared/appearance/ConfigAppearance.qml` is the common Appearance page.
`scripts/sync-shared.sh` vendors those files into each plasmoid so Store packages stay self-contained.

## Package all widgets

```bash
./scripts/package.sh
```

Writes `dist/`:

- `com.koollook.celestialsky-1.4.0.plasmoid`
- `com.koollook.celestialsky-1.4.0.plasmoid`
- `com.koollook.calendar-2.0.0.plasmoid`
- `com.koollook.weather-2.0.0.plasmoid`
- `koollook-widgets-2.0.0.tar.zst`
- `SHA256SUMS`
GitHub Actions on `main` and `v*` tags produce the same artifacts.

## Install

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
shared/glass/                  org.koollook.glass
shared/location/               org.koollook.location
shared/appearance/             ConfigAppearance.qml
plasmoids/com.koollook.*/      widget-specific sources
scripts/package.sh             builds all three

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

MIT — see `LICENSE`. All widgets and QML are MIT.

## Changelog

See `CHANGELOG.md`.
