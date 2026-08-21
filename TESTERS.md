# Koollook tester pack (GitHub Releases)

Plasma 6. Installs into **this user’s** `~/.local` (no root). You choose what to install.

## From a GitHub Release

Download either:

- `koollook-2.8.0.tar.zst` — everything + chooser `install.sh`
- only the pieces you want (`com.koollook.*.plasmoid`, `koollook-theme-*.tar.zst`, `koollook-accessibility-*.tar.zst`)

```bash
tar -I zstd -xf koollook-2.8.0.tar.zst
cd koollook-2.8.0
chmod +x install.sh
./install.sh                 # asks yes/no per piece
# or:
./install.sh --planisphere --weather
./install.sh --theme --dotted
./install.sh --all           # files only; does not restyle your session
./install.sh --all --apply   # also switch colors/icons/Koollook title bar
```

`--apply` is optional. **Koollook Dotted** is a separate title bar (`--dotted`).

Restart Plasma if the UI does not update:

```bash
kquitapp6 plasmashell; kstart plasmashell
```

Then: Add Widgets → Koollook. Window Decorations → **Koollook** or **Koollook Dotted**.
