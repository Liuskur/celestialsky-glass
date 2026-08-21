#!/usr/bin/env bash
# Vendor shared/glass + Appearance config into each plasmoid (self-contained packages).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/shared/glass"
APP="$ROOT/shared/appearance/ConfigAppearance.qml"

[[ -f "$SRC/qmldir" ]] || { echo "missing $SRC/qmldir" >&2; exit 1; }
[[ -f "$APP" ]] || { echo "missing $APP" >&2; exit 1; }

for id in com.koollook.celestialsky com.koollook.calendar com.koollook.weather; do
  ui="$ROOT/plasmoids/$id/contents/ui"
  dest="$ui/org/koollook/glass"
  rm -rf "$dest"
  mkdir -p "$dest"
  cp -a "$SRC"/. "$dest/"
  mkdir -p "$ui/config"
  cp -a "$APP" "$ui/config/ConfigAppearance.qml"
done
