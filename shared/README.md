# Shared Koollook components

`glass/` is QML module `org.koollook.glass` (`LiquidGlass`, `MacOSColors`, shaders).

`location/` is QML module `org.koollook.location` (`LocationSearch` via Open-Meteo geocoding).

`appearance/ConfigAppearance.qml` is the common Appearance settings page (Copy/Paste style, glass/solid, refraction, blur).

`scripts/sync-shared.sh` copies these into each plasmoid so Store packages stay self-contained:

- `contents/ui/org/koollook/glass/`
- `contents/ui/org/koollook/location/`
- `contents/ui/config/ConfigAppearance.qml`

Do not edit copies inside `plasmoids/`; edit here.

License: MIT (see `/LICENSE`).
