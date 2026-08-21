# Koollook theme pack

Plasma 6 look pieces.

| Piece | Id | Source |
|-------|-----|--------|
| Color schemes | `Koollook` (dark), `KoollookAqua`, `KoollookEesti`, `KoollookLiwi` | Stone2 + aqua / Eesti / Liwi flags |
| Icons | `Koollook` | Liwi-style griffin (teal `#00d3b8`); launcher is `start-here-kde` |
| Aurorae decoration | `Koollook` | Willow Dark Alt Shader |
| Aurorae decoration | `Koollook Dotted` | KDE 2 stippled title bar (separate option) |
| KDE 2 C++ plugin | `org.koollook.kde2` | kdecoration2-kde2 → KDecoration3 (optional build) |
| KWin effects | translucency, hide-cursor | RiderLook kwinrc |

```bash
./theme/install.sh
```

Schemes: **Koollook Dark**, **Koollook Aqua** (light), **Koollook Eesti** (blue/black/white), **Koollook Liwi** (green/white/blue). Apply in System Settings → Colors.

Icons: regular griffin on gules, white glyph, charcoal glyph, ColorScheme symbolic. Application launcher uses the regular griffin (`start-here-kde`).

Widget styles (Glass / Clear / Plasma / Chameleon / Inverse / Koollook) are in `shared/glass/KoollookFrame.qml`.
