# Koollook theme pack

Plasma 6 look pieces.

| Piece | Id | Source |
|-------|-----|--------|
| Color schemes | `Koollook` (dark), `KoollookAqua`, `KoollookEesti`, `KoollookLivonia` | Stone2 + aqua / Eesti / Livonian flags |
| Icons | `Koollook` | Livonian-style griffin; launcher is `start-here-kde` |
| Aurorae decoration | `Koollook` | Willow Dark Alt Shader |
| KDE 2 decoration | `org.koollook.kde2` | kdecoration2-kde2 → KDecoration3 |
| Global theme | `org.koollook.desktop` | RiderLook |
| KWin effects | translucency, hide-cursor | RiderLook kwinrc |

```bash
./theme/install.sh
```

Schemes: **Koollook Dark**, **Koollook Aqua** (light), **Koollook Eesti** (blue/black/white), **Koollook Livonia** (green/white/blue). Apply in System Settings → Colors.

Icons: regular griffin on gules, white glyph, charcoal glyph, ColorScheme symbolic. Application launcher uses the regular griffin (`start-here-kde`).

Widget styles (Glass / Clear / Plasma / Chameleon / Inverse / Koollook) are in `shared/glass/KoollookFrame.qml`.
