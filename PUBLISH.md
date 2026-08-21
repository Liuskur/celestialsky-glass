# TODO: publish Koollook and clean GitHub

## GitHub (`Liuskur/KoollooK`)

- [x] Repository renamed to `KoollooK`. Clone URL: `https://github.com/Liuskur/KoollooK`. Website fields in `metadata.json` updated.
- [ ] Set description, topics: `kde`, `plasma-6`, `plasmoid`, `aurorae` (KWin engine topic, not product name).
- [ ] Replace leftover RiderLook / MacOS wording in READMEs and plugin Website URLs. Sky widget is **Koollook Planisphere**.
- [ ] Drop secrets and machine paths: no `/opt/Grok`, no `/home/rider`, no ResoNider absolute paths in shipped scripts (use env vars only).
- [ ] `.gitignore`: `/dist/`, decoration `build/`, vendored `contents/ui/org/`, `error.txt`, screenshots of the local desktop.
- [ ] Do not commit `.git` inside third-party tarballs (kdecoration2-kde2).
- [ ] LICENSE: widgets MIT; KoollooK title-bar SVGs (Willow) GPL-3.0 — keep that split visible on the repo front page.
- [ ] Add screenshots (launcher griffin, Dotted vs Koollook title bars, four color schemes, STT tray) — no personal files on the desktop.
- [ ] CI: `scripts/package.sh` on Plasma 6; optional compile of `org.koollook.kde2` if ECM is present.
- [ ] Tag `v2.6.0` after the rename; attach `koollook-2.6.0.tar.zst`.

## KDE Store / distro

- [ ] One Store entry per plasmoid (`com.koollook.*`) plus separate theme pieces (colors, icons, title bar, Dotted, splash, SDDM, Plymouth, each wallpaper).
- [ ] Accessibility pack as a separate Store item (STT helper is not a plasmoid-only zip).
- [ ] Short Store blurbs; required Plasma 6; MIT except Willow title-bar SVGs GPL-3.0.
- [ ] Distro: split packages per piece; also ship `koollook` metapackage / suite tarball. Theme install must not overwrite the user’s color scheme unless they opt in.

## Product gaps before “world”

- [ ] STT helper: document that typing is AT-SPI on KWin (not wtype). Optional ydotool.
- [ ] C++ `org.koollook.kde2` needs cmake + extra-cmake-modules; testers use **KoollooK Dotted** until that builds everywhere.
- [ ] `astronomy.js` QML used-before-declared warnings.
- [ ] Tester pack: people run `./install.sh` then pick **Koollook Dotted** in Window Decorations.

## What testers should already have

`scripts/package.sh` writes per-piece `dist/koollook-*-<ver>.tar.zst` plus suite `dist/koollook-<ver>.tar.zst`. Extract the bundle and `./install.sh` (see `TESTERS.md`).
