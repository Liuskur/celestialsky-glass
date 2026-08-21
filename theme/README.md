# Koollook theme pack

Plasma 6 look pieces.

| Piece | Id | Source |
|-------|-----|--------|
| Color scheme | `Koollook` | Stone2 |
| Aurorae decoration | `Koollook` | Willow Dark Alt Shader |
| KDE 2 decoration | `org.koollook.kde2` | kdecoration2-kde2 → KDecoration3 |
| Global theme | `org.koollook.desktop` | RiderLook |
| KWin effects | translucency, hide-cursor | RiderLook kwinrc |

```bash
./theme/install.sh
```

Widget styles (Glass / Clear / Plasma / Chameleon / Inverse / Koollook) are in `shared/glass/KoollookFrame.qml` — one change applies to every plasmoid.

KDE 2 C++ decoration needs cmake + KF6 + KDecoration3 (`cmake` on PATH). Aurorae `Koollook` always installs.
