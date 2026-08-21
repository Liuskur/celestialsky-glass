#!/usr/bin/env bash
# Install Koollook color scheme, window decoration, look-and-feel, KWin effects.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOME_SHARE="${XDG_DATA_HOME:-$HOME/.local/share}"
APPLY_LAYOUT="${APPLY_LAYOUT:-0}"

mkdir -p "$HOME_SHARE/color-schemes" \
         "$HOME_SHARE/aurorae/themes" \
         "$HOME_SHARE/plasma/look-and-feel" \
         "$HOME_SHARE/icons"

cp -a "$ROOT/theme/color-schemes/"*.colors "$HOME_SHARE/color-schemes/"
rm -rf "$HOME_SHARE/aurorae/themes/Koollook"
cp -a "$ROOT/theme/window-decoration/Koollook" "$HOME_SHARE/aurorae/themes/Koollook"
rm -rf "$HOME_SHARE/plasma/look-and-feel/org.koollook.desktop"
cp -a "$ROOT/theme/look-and-feel/org.koollook.desktop" "$HOME_SHARE/plasma/look-and-feel/"
rm -rf "$HOME_SHARE/icons/Koollook"
cp -a "$ROOT/theme/icons/Koollook" "$HOME_SHARE/icons/Koollook"

if command -v plasma-apply-colorscheme >/dev/null; then
  plasma-apply-colorscheme Koollook >/dev/null || true
fi
if command -v plasma-apply-icontheme >/dev/null; then
  plasma-apply-icontheme Koollook >/dev/null || true
fi

kwriteconfig6 --file kdeglobals --group General --key ColorScheme Koollook
kwriteconfig6 --file kdeglobals --group General --key AccentColor "0,211,184"
kwriteconfig6 --file kdeglobals --group Icons --key Theme Koollook
kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage org.koollook.desktop

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
fi

echo "Koollook theme installed (colors, Koollook Aurorae, KWin effects)."
echo "Global theme: org.koollook.desktop  (APPLY_LAYOUT=1 to also load layout)"
