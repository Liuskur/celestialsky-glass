#!/usr/bin/env bash
# Package and install all Koollook Plasma applets, theme, and STT.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/package.sh"
for f in "$ROOT/dist"/com.koollook.*.plasmoid; do
  kpackagetool6 -t Plasma/Applet -u "$f" 2>/dev/null || kpackagetool6 -t Plasma/Applet -i "$f"
done
"$ROOT/theme/install.sh"
"$ROOT/accessibility/koollook-stt/install.sh"
echo "Koollook widgets, theme, and STT updated locally."
