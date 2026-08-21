#!/usr/bin/env bash
# Install a Koollook release dir on this machine (user ~/.local, Plasma 6).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
shopt -s nullglob

for f in "$HERE"/com.koollook.*.plasmoid; do
  kpackagetool6 -t Plasma/Applet -u "$f" 2>/dev/null || kpackagetool6 -t Plasma/Applet -i "$f"
done

install_tar() {
  local archive="$1"
  [[ -f "$archive" ]] || return 0
  local tmp
  tmp="$(mktemp -d)"
  tar -C "$tmp" -xf "$archive"
  if [[ -x "$tmp/theme/install.sh" ]]; then
    (cd "$tmp" && ./theme/install.sh)
  elif [[ -x "$tmp/accessibility/koollook-stt/install.sh" ]]; then
    (cd "$tmp" && ./accessibility/koollook-stt/install.sh)
  fi
  rm -rf "$tmp"
}

for f in "$HERE"/koollook-theme-*.tar.zst; do install_tar "$f"; done
for f in "$HERE"/koollook-accessibility-*.tar.zst; do install_tar "$f"; done

echo "Koollook installed for $USER."
echo "Restart Plasma: kquitapp6 plasmashell; kstart plasmashell"
echo "Window Decorations: Koollook  or  Koollook Dotted"
