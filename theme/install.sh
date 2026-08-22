#!/usr/bin/env bash
# Install Koollook color scheme, Plasma style, window decoration, look-and-feel, KWin effects.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOME_SHARE="${XDG_DATA_HOME:-$HOME/.local/share}"
APPLY_LAYOUT="${APPLY_LAYOUT:-0}"

mkdir -p "$HOME_SHARE/color-schemes" \
         "$HOME_SHARE/aurorae/themes" \
         "$HOME_SHARE/plasma/look-and-feel" \
         "$HOME_SHARE/plasma/desktoptheme" \
         "$HOME_SHARE/icons" \
         "$HOME_SHARE/wallpapers" \
         "$HOME_SHARE/sddm/themes"

cp -a "$ROOT/theme/color-schemes/"*.colors "$HOME_SHARE/color-schemes/"
rm -rf "$HOME_SHARE/aurorae/themes/Koollook"
cp -a "$ROOT/theme/window-decoration/Koollook" "$HOME_SHARE/aurorae/themes/Koollook"
rm -rf "$HOME_SHARE/aurorae/themes/KoollookDotted"
cp -a "$ROOT/theme/window-decoration/KoollookDotted" "$HOME_SHARE/aurorae/themes/KoollookDotted"
mkdir -p "$HOME_SHARE/kwin/aurorae"
cp -a "$ROOT/theme/kwin-aurorae/"*.qml "$HOME_SHARE/kwin/aurorae/"
SYS_AURORAE="/usr/share/kwin/aurorae"
if [[ -d "$SYS_AURORAE" ]]; then
  for f in aurorae.qml AuroraeButtonGroup.qml AppMenuButton.qml; do
    if [[ -f "$SYS_AURORAE/$f" && ! -f "$SYS_AURORAE/$f.bak-koollook" ]]; then
      cp -a "$SYS_AURORAE/$f" "$SYS_AURORAE/$f.bak-koollook" 2>/dev/null || true
    fi
    cp -a "$ROOT/theme/kwin-aurorae/$f" "$SYS_AURORAE/$f" 2>/dev/null || true
  done
fi
mkdir -p "$HOME_SHARE/kwin/decorations"
rm -rf "$HOME_SHARE/kwin/decorations/org.koollook.dotted"
cp -a "$ROOT/theme/window-decoration/org.koollook.dotted" "$HOME_SHARE/kwin/decorations/org.koollook.dotted"
rm -rf "$HOME_SHARE/plasma/look-and-feel/org.koollook.desktop"
cp -a "$ROOT/theme/look-and-feel/org.koollook.desktop" "$HOME_SHARE/plasma/look-and-feel/"
rm -rf "$HOME_SHARE/plasma/look-and-feel/org.koollook.light.desktop"
cp -a "$ROOT/theme/look-and-feel/org.koollook.light.desktop" "$HOME_SHARE/plasma/look-and-feel/"
rm -rf "$HOME_SHARE/plasma/desktoptheme/Koollook"
cp -a "$ROOT/theme/plasma/desktoptheme/Koollook" "$HOME_SHARE/plasma/desktoptheme/Koollook"
rm -rf "$HOME_SHARE/icons/Koollook"
cp -a "$ROOT/theme/icons/Koollook" "$HOME_SHARE/icons/Koollook"
for d in "$ROOT/theme/wallpapers/"*; do
  [[ -d "$d" ]] || continue
  name="$(basename "$d")"
  rm -rf "$HOME_SHARE/wallpapers/$name"
  cp -a "$d" "$HOME_SHARE/wallpapers/$name"
done
rm -rf "$HOME_SHARE/sddm/themes/Koollook"
cp -a "$ROOT/theme/sddm/Koollook" "$HOME_SHARE/sddm/themes/Koollook"

if command -v plasma-apply-colorscheme >/dev/null; then
  plasma-apply-colorscheme Koollook >/dev/null || true
fi
if command -v plasma-apply-icontheme >/dev/null; then
  plasma-apply-icontheme Koollook >/dev/null || true
fi
if command -v plasma-apply-desktoptheme >/dev/null; then
  plasma-apply-desktoptheme Koollook >/dev/null || true
fi

kwriteconfig6 --file kdeglobals --group General --key ColorScheme Koollook
kwriteconfig6 --file kdeglobals --group General --key AccentColor "0,211,184"
kwriteconfig6 --file kdeglobals --group Icons --key Theme Koollook
kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage org.koollook.desktop
kwriteconfig6 --file plasmarc --group Theme --key name Koollook
kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML
kwriteconfig6 --file ksplashrc --group KSplash --key Theme org.koollook.desktop
WP="$HOME_SHARE/wallpapers/Koollook/contents/images/3840x2160.png"
if command -v plasma-apply-wallpaperimage >/dev/null && [[ -f "$WP" ]]; then
  plasma-apply-wallpaperimage "$WP" >/dev/null 2>&1 || true
fi

kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae.v2
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme '__aurorae__svg__Koollook'
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft M
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight IAX
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key BorderSizeAuto false
kwriteconfig6 --file kwinrc --group Plugins --key translucencyEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key hidecursorEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key slideEnabled false
kwriteconfig6 --file kwinrc --group Effect-translucency --key IndividualMenuConfig true
kwriteconfig6 --file kwinrc --group Effect-translucency --key ExcludeFullScreen true
kwriteconfig6 --file kwinrc --group Effect-translucency --key MoveResize 63
kwriteconfig6 --file kwinrc --group Effect-translucency --key DropdownMenus 66
kwriteconfig6 --file kwinrc --group Effect-translucency --key PopupMenus 66
kwriteconfig6 --file kwinrc --group Effect-translucency --key TornOffMenus 67
kwriteconfig6 --file kwinrc --group Windows --key Placement Smart
kwriteconfig6 --file kwinrc --group TabBox --key LayoutName thumbnail_grid
kwriteconfig6 --file kwinrc --group WindowSwitcher --key LayoutName thumbnail_grid

if command -v qdbus6 >/dev/null; then
  qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
elif command -v qdbus >/dev/null; then
  qdbus org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
fi

if [[ "$APPLY_LAYOUT" == 1 ]] && command -v lookandfeeltool >/dev/null; then
  lookandfeeltool -a org.koollook.desktop
fi

DECO="$ROOT/theme/window-decoration/kdecoration-kde2"
if command -v cmake >/dev/null && [[ -f "$DECO/CMakeLists.txt" ]]; then
  cmake -B "$DECO/build" -S "$DECO" \
    -DCMAKE_INSTALL_PREFIX="${HOME}/.local" \
    -DCMAKE_BUILD_TYPE=Release >/tmp/koollook-kde2-cmake.log 2>&1 \
    && cmake --build "$DECO/build" -j"$(nproc)" >/tmp/koollook-kde2-build.log 2>&1 \
    && cmake --install "$DECO/build" >/tmp/koollook-kde2-install.log 2>&1 \
    && echo "Koollook KDE 2 decoration installed to ~/.local" \
    || echo "KDE 2 decoration build skipped (see /tmp/koollook-kde2-*.log)"
echo "KoollooK theme installed (color schemes, griffin icons, Plasma style, title bar, KWin)."
echo "Window decorations: Koollook (default) and Koollook Dotted."
echo "Plasma style: Koollook. Global themes: Koollook (dark) and Koollook Light."
echo "Colors: Koollook Dark, Koollook Light, Aqua, Eesti, Liwi"
echo "Plasma style: Koollook (Stone layout). Global theme: org.koollook.desktop  (APPLY_LAYOUT=1 to also load layout)"
echo "Colors: Koollook Dark (default), Koollook Aqua, Koollook Eesti, Koollook Liwi"
