#!/usr/bin/env bash
# Install Koollook color scheme, window decoration, look-and-feel, KWin effects.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOME_SHARE="${XDG_DATA_HOME:-$HOME/.local/share}"
APPLY_LAYOUT="${APPLY_LAYOUT:-0}"

mkdir -p "$HOME_SHARE/color-schemes" \
         "$HOME_SHARE/aurorae/themes" \
         "$HOME_SHARE/plasma/look-and-feel"

cp -a "$ROOT/theme/color-schemes/Koollook.colors" "$HOME_SHARE/color-schemes/"
rm -rf "$HOME_SHARE/aurorae/themes/Koollook"
cp -a "$ROOT/theme/window-decoration/Koollook" "$HOME_SHARE/aurorae/themes/Koollook"
rm -rf "$HOME_SHARE/plasma/look-and-feel/org.koollook.desktop"
cp -a "$ROOT/theme/look-and-feel/org.koollook.desktop" "$HOME_SHARE/plasma/look-and-feel/"

if command -v plasma-apply-colorscheme >/dev/null; then
  plasma-apply-colorscheme Koollook >/dev/null || true
fi

kwriteconfig6 --file kdeglobals --group General --key ColorScheme Koollook
kwriteconfig6 --file kdeglobals --group General --key AccentColor "0,211,184"
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

echo "Koollook theme installed (colors, Koollook decoration, KWin effects)."
echo "Global theme: org.koollook.desktop  (APPLY_LAYOUT=1 to also load layout)"
