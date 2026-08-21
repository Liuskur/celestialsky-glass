# Koollook 0.7.2

Plasma 6 only. Each piece is its own tarball so you only download what you want.
`koollook-0.7.2.tar.zst` is the full bundle (every piece + chooser `install.sh`).

```bash
tar -I zstd -xf koollook-0.7.2.tar.zst
cd koollook-0.7.2
./install.sh --help
./install.sh                  # yes/no per component
./install.sh --all            # all files, keep your current look
./install.sh --all --apply    # also switch to Koollook colors/icons/title bar
./install.sh --muhurta --hora
./install.sh --splash --colors --titlebar
```

Splash wordmark: **KoollooK**. Title bar pack is `koollook-titlebar` (KWin Aurorae engine unchanged).

## Assets

| File | What |
|------|------|
| `koollook-0.7.2.tar.zst` | Full bundle + chooser `install.sh` |
| `com.koollook.*.plasmoid` | Single widgets (Store-style) |
| `koollook-colors-0.7.2.tar.zst` | Color schemes |
| `koollook-icons-0.7.2.tar.zst` | Griffin icons |
| `koollook-titlebar-0.7.2.tar.zst` | KoollooK title bar |
| `koollook-dotted-0.7.2.tar.zst` | Koollook Dotted title bar |
| `koollook-splash-0.7.2.tar.zst` | Plasma splash (KoollooK) |
| `koollook-sddm-0.7.2.tar.zst` | Login theme |
| `koollook-plymouth-0.7.2.tar.zst` | Boot splash |
| `koollook-wallpaper-0.7.2.tar.zst` | Default wallpaper |
| `koollook-wallpaper-1` … `7` | Extra wallpapers (large) |
| `koollook-accessibility-0.7.2.tar.zst` | STT helper |

Widgets: Planisphere, Calendar, Weather, Muhurta, Hora, STT Clip, STT tray, Wavebar.
Window decorations: **Koollook** and **Koollook Dotted** (`--dotted`).

After install: `kquitapp6 plasmashell; kstart plasmashell`
