# Koollook 0.7.3

Plasma 6 only. Each piece is its own tarball so you only download what you want.
`koollook-0.7.3.tar.zst` is the full bundle (every piece + chooser `install.sh`).

```bash
tar -I zstd -xf koollook-0.7.3.tar.zst
cd koollook-0.7.3
./install.sh --help
./install.sh                  # yes/no per component
./install.sh --all            # all files, keep your current look
./install.sh --all --apply    # also switch to Koollook colors/icons/title bar
./install.sh --muhurta --hora
./install.sh --splash --colors --titlebar --plasma
```

Splash wordmark: **KoollooK**. Title bar pack is `koollook-titlebar` (KWin Aurorae engine unchanged).

## 0.7.3

- Dotted title bar follows the active color scheme (light and dark)
- Dotted dots use Common Colors **Tooltip Background**
- Aqua: cloudy sea-mist palette
- Eesti: white field, black chrome, blue titlebar
- Liwi: white buttons; white symbolic griffin
- Light griffin + wallpaper `Koollook-Light`
- Plasma style **Koollook** (Stone layout)

## Assets

| File | What |
|------|------|
| `koollook-0.7.3.tar.zst` | Full bundle + chooser `install.sh` |
| `com.koollook.*.plasmoid` | Single widgets (Store-style) |
| `koollook-colors-0.7.3.tar.zst` | Color schemes |
| `koollook-icons-0.7.3.tar.zst` | Griffin icons |
| `koollook-plasma-0.7.3.tar.zst` | Plasma style |
| `koollook-titlebar-0.7.3.tar.zst` | KoollooK title bar |
| `koollook-dotted-0.7.3.tar.zst` | Koollook Dotted title bar |
| `koollook-splash-0.7.3.tar.zst` | Plasma splash (KoollooK) |
| `koollook-sddm-0.7.3.tar.zst` | Login theme |
| `koollook-plymouth-0.7.3.tar.zst` | Boot splash |
| `koollook-wallpaper-0.7.3.tar.zst` | Default wallpaper |
| `koollook-wallpaper-1` … `7` | Extra wallpapers (large) |
| `koollook-wallpaper-Koollook-Light-0.7.3.tar.zst` | Light griffin wallpaper |
| `koollook-accessibility-0.7.3.tar.zst` | STT helper |

Widgets: Planisphere, Calendar, Weather, Muhurta, Hora, STT Clip, STT tray, Wavebar.
Window decorations: **Koollook** and **Koollook Dotted** (`--dotted`).

After install: `kquitapp6 plasmashell; kstart plasmashell`
