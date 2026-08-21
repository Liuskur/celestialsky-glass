# Koollook tester pack (GitHub Releases)

Plasma 6. Installs into **this user’s** `~/.local` (no root). You choose what to install.

## From a GitHub Release

Download either:

- `koollook-0.7.2.tar.zst` — everything + chooser `install.sh`
- only the pieces you want (`com.koollook.*.plasmoid`, `koollook-colors-*.tar.zst`, `koollook-splash-*.tar.zst`, wallpapers, …)

```bash
tar -I zstd -xf koollook-0.7.2.tar.zst
cd koollook-0.7.2
chmod +x install.sh
./install.sh                 # asks yes/no per piece
# or:
./install.sh --planisphere --weather
./install.sh --theme --dotted
./install.sh --splash        # Plasma splash, wordmark KoollooK
./install.sh --all           # files only; does not restyle your session
./install.sh --all --apply   # also switch colors/icons/Koollook title bar
```

`--apply` is optional. **Koollook Dotted** is a separate title bar (`--dotted`).
Wallpapers 1–7 are large; skip them unless you want those images.

Restart Plasma if the UI does not update:

```bash
kquitapp6 plasmashell; kstart plasmashell
```

Then: Add Widgets → Koollook. Window Decorations → **Koollook** or **Koollook Dotted**.
