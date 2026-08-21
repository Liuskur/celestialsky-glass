# Koollook 2.8.0 (tester)

Plasma 6 only. Download `koollook-2.8.0.tar.zst`, extract, run `./install.sh` and pick pieces (or use flags). No root.

```bash
tar -I zstd -xf koollook-2.8.0.tar.zst
cd koollook-2.8.0
./install.sh --help
./install.sh                  # yes/no per component
./install.sh --all            # all files, keep your current look
./install.sh --all --apply    # also switch to Koollook colors/icons/title bar
./install.sh --muhurta --hora
```

## Assets

| File | What |
|------|------|
| `koollook-2.8.0.tar.zst` | Full pack + chooser `install.sh` |
| `koollook-widgets-2.8.0.tar.zst` | All plasmoids |
| `koollook-theme-2.8.0.tar.zst` | Colors, icons, Koollook + Koollook Dotted |
| `koollook-accessibility-2.8.0.tar.zst` | STT helper |
| `com.koollook.*.plasmoid` | Single widgets (Store-style) |

Widgets: Planisphere, Calendar, Weather, Muhurta, Hora, STT Clip, STT tray, Wavebar.
Window decorations: **Koollook** (default bar) and **Koollook Dotted** (KDE 2 stipple) — install Dotted with `--dotted`, then pick it in System Settings.

After install: `kquitapp6 plasmashell; kstart plasmashell`
