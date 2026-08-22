# Koollook theme pack

Plasma 6 look pieces.

| Piece | Id | Source |
|-------|-----|--------|
| Color schemes | `Koollook` (dark), `KoollookAqua`, `KoollookEesti`, `KoollookLiwi` | Stone2 + aqua / Eesti / Liwi flags |
| Plasma style | `Koollook` | Stone desktop theme, rebranded |
| Icons | `Koollook` | Teal griffin; light tile in `src/griffin-light.png`; launcher is `start-here-kde` |
| Wallpaper | `Koollook` | Same griffin, Koollook Dark |
| Wallpaper | `Koollook-Light` | Same griffin, light cloudy field |
| KSplash / SDDM / Plymouth | griffin lock-in border; splash wordmark **KoollooK** | `theme/sddm`, `contents/splash`, `theme/plymouth` |
| Window decoration | `Koollook` | Willow Dark Alt Shader |
| Window decoration | `Koollook Dotted` | KDE 2 stippled title bar; dots = Common Colors Tooltip Background |

```bash
./theme/install.sh
```

Schemes: **Koollook Dark**, **Koollook Aqua** (light, cloudy sea-mist), **Koollook Eesti** (white field, black chrome, blue banner), **Koollook Liwi** (green windows, white buttons, blue selection). Apply in System Settings → Colors.

Icons: regular griffin on gules, white glyph, charcoal glyph, ColorScheme symbolic (white). Application launcher uses the regular griffin (`start-here-kde`).

Widget styles (Glass / Clear / Plasma / Chameleon / Inverse / Koollook) are in `shared/glass/KoollookFrame.qml`.
