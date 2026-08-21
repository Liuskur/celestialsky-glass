# Shared Koollook components

`glass/` is QML module `org.koollook.glass` (`LiquidGlass`, `MacOSColors`, shaders).

`appearance/ConfigAppearance.qml` is the common Appearance settings page (Copy/Paste style, glass/solid, refraction, blur).

`scripts/sync-shared.sh` copies these into each plasmoid so Store packages stay self-contained:

- `contents/ui/org/koollook/glass/`
- `contents/ui/config/ConfigAppearance.qml`

Do not edit copies inside `plasmoids/`; edit here.
