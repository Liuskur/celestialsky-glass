#!/usr/bin/env bash
# Vendor shared glass, location, and Appearance config into each plasmoid.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GLASS="$ROOT/shared/glass"
LOC="$ROOT/shared/location"
APP="$ROOT/shared/appearance/ConfigAppearance.qml"

[[ -f "$GLASS/qmldir" ]] || { echo "missing $GLASS/qmldir" >&2; exit 1; }
[[ -f "$LOC/qmldir" ]] || { echo "missing $LOC/qmldir" >&2; exit 1; }
[[ -f "$APP" ]] || { echo "missing $APP" >&2; exit 1; }

for id in com.koollook.celestialsky com.koollook.calendar com.koollook.weather com.koollook.sttclip com.koollook.audioviz; do
  ui="$ROOT/plasmoids/$id/contents/ui"
  mkdir -p "$ui/org/koollook/glass" "$ui/org/koollook/location" "$ui/config"
  rm -rf "$ui/org/koollook/glass" "$ui/org/koollook/location"
  mkdir -p "$ui/org/koollook/glass" "$ui/org/koollook/location"
  cp -a "$GLASS"/. "$ui/org/koollook/glass/"
  cp -a "$LOC"/. "$ui/org/koollook/location/"
  cp -a "$APP" "$ui/config/ConfigAppearance.qml"
done
