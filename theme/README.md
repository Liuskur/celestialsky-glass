# Koollook theme (from RiderLook)

Plasma 6 look pieces, rebranded from the RiderLook stack.

| Piece | Id | Source |
|-------|-----|--------|
| Color scheme | `Koollook` | Stone2 |
| Window decoration | Aurorae `Koollook` | Willow Dark Alt Shader |
| Global theme | `org.koollook.desktop` | RiderLook defaults |
| KWin effects | translucency, hide-cursor, no slide, thumbnail switcher | RiderLook `kwinrc` |

```bash
./theme/install.sh              # install + apply colors/decoration/effects
APPLY_LAYOUT=1 ./theme/install.sh   # also apply desktop/panel layout
```

Window decoration SVGs remain GPL-3.0 (Willow / doncsugar). Color scheme and look-and-feel defaults are MIT.

Plasma style still expects **lavender-round** and **Tela** icons if those packages are present; otherwise Breeze is used.
