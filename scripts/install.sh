#!/usr/bin/env bash
# Package and install all three Koollook Plasma applets.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/package.sh"
for f in "$ROOT/dist"/com.koollook.*.plasmoid; do
  kpackagetool6 -t Plasma/Applet -u "$f" 2>/dev/null || kpackagetool6 -t Plasma/Applet -i "$f"
done
