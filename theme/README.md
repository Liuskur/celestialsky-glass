# Koollook theme pack

Plasma 6 look pieces.

| Piece | Id | Source |
|-------|-----|--------|
| Color schemes | `Koollook` (dark), `KoollookAqua`, `KoollookEesti`, `KoollookLiwi` | Stone2 + aqua / Eesti / Liwi flags |
| Icons | `Koollook` | Teal griffin; launcher is `start-here-kde` |
| Wallpaper | `Koollook` | Same griffin, Koollook Dark |
| KSplash / SDDM / Plymouth | griffin lock-in border; splash wordmark **KoollooK** | `theme/sddm`, `contents/splash`, `theme/plymouth` |
| Window decoration | `Koollook` | Willow Dark Alt Shader |
| Window decoration | `Koollook Dotted` | KDE 2 stippled title bar (separate option) |

```bash
./theme/install.sh
```

Schemes: **Koollook Dark**, **Koollook Aqua** (light), **Koollook Eesti** (blue/black/white), **Koollook Liwi** (green/white/blue). Apply in System Settings → Colors.

Icons: regular griffin on gules, white glyph, charcoal glyph, ColorScheme symbolic. Application launcher uses the regular griffin (`start-here-kde`).

Widget styles (Glass / Clear / Plasma / Chameleon / Inverse / Koollook) are in `shared/glass/KoollookFrame.qml`.
