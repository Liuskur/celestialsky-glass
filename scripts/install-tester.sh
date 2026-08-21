#!/usr/bin/env bash
# Install this Koollook tester pack on the machine that runs the script.
# Requires: Plasma 6, kpackagetool6, kwriteconfig6. No root required.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SHARE="${XDG_DATA_HOME:-$HOME/.local/share}"
BIN="${XDG_BIN_HOME:-$HOME/.local/bin}"

echo "Installing Koollook for $USER (Plasma 6 user dirs)…"

shopt -s nullglob
for f in "$HERE"/com.koollook.*.plasmoid; do
  kpackagetool6 -t Plasma/Applet -u "$f" 2>/dev/null || kpackagetool6 -t Plasma/Applet -i "$f"
done

if [[ -x "$HERE/theme/install.sh" ]]; then
  (cd "$HERE" && ./theme/install.sh)
elif [[ -d "$HERE/theme" ]]; then
  mkdir -p "$SHARE/color-schemes" "$SHARE/aurorae/themes" "$SHARE/plasma/look-and-feel" "$SHARE/icons"
  cp -a "$HERE/theme/color-schemes/"*.colors "$SHARE/color-schemes/" 2>/dev/null || true
  [[ -d "$HERE/theme/window-decoration/Koollook" ]] && rm -rf "$SHARE/aurorae/themes/Koollook" && cp -a "$HERE/theme/window-decoration/Koollook" "$SHARE/aurorae/themes/Koollook"
  [[ -d "$HERE/theme/window-decoration/KoollookDotted" ]] && rm -rf "$SHARE/aurorae/themes/KoollookDotted" && cp -a "$HERE/theme/window-decoration/KoollookDotted" "$SHARE/aurorae/themes/KoollookDotted"
  [[ -d "$HERE/theme/look-and-feel/org.koollook.desktop" ]] && rm -rf "$SHARE/plasma/look-and-feel/org.koollook.desktop" && cp -a "$HERE/theme/look-and-feel/org.koollook.desktop" "$SHARE/plasma/look-and-feel/"
  [[ -d "$HERE/theme/icons/Koollook" ]] && rm -rf "$SHARE/icons/Koollook" && cp -a "$HERE/theme/icons/Koollook" "$SHARE/icons/Koollook"
fi

if [[ -x "$HERE/accessibility/koollook-stt/install.sh" ]]; then
  (cd "$HERE" && ./accessibility/koollook-stt/install.sh)
fi

echo
echo "Installed. Restart Plasma if widgets/icons/decorations do not appear:"
echo "  kquitapp6 plasmashell; kstart plasmashell"
echo
echo "Then:"
echo "  Desktop → Add Widgets → search Koollook"
echo "  System Settings → Colors → Koollook Dark / Aqua / Eesti / Liwi"
echo "  System Settings → Icons → Koollook"
echo "  System Settings → Window Decorations → Koollook  or  Koollook Dotted"
echo "  (Dotted is the KDE 2 stippled title bar; Koollook is the glass/Willow bar.)"
