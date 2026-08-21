#!/usr/bin/env bash
# Install a Koollook release dir (plasmoids + theme + STT).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

for f in "$HERE"/com.koollook.*.plasmoid; do
  [[ -e "$f" ]] || continue
  kpackagetool6 -t Plasma/Applet -u "$f" 2>/dev/null || kpackagetool6 -t Plasma/Applet -i "$f"
done

if [[ -f "$HERE"/koollook-theme-*.tar.zst ]]; then
  tmp="$(mktemp -d)"
  tar -C "$tmp" -xf "$HERE"/koollook-theme-*.tar.zst
  if [[ -x "$tmp/theme/install.sh" ]]; then
    (cd "$tmp" && ./theme/install.sh)
  fi
  rm -rf "$tmp"
fi

if [[ -f "$HERE"/koollook-stt-*.tar.zst ]]; then
  tmp="$(mktemp -d)"
  tar -C "$tmp" -xf "$HERE"/koollook-stt-*.tar.zst
  if [[ -x "$tmp/accessibility/koollook-stt/install.sh" ]]; then
    (cd "$tmp" && ./accessibility/koollook-stt/install.sh)
  fi
  rm -rf "$tmp"
fi

echo "Koollook release installed."
