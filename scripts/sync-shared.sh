#!/usr/bin/env bash
# Vendor shared glass, location, Appearance, and timekeeping into each plasmoid.
# Also vendor timekeeping JS/CSS into the standalone Muhurta and Hora sites.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GLASS="$ROOT/shared/glass"
LOC="$ROOT/shared/location"
APP="$ROOT/shared/appearance/ConfigAppearance.qml"
TIME="$ROOT/shared/timekeeping"

[[ -f "$GLASS/qmldir" ]] || { echo "missing $GLASS/qmldir" >&2; exit 1; }
[[ -f "$LOC/qmldir" ]] || { echo "missing $LOC/qmldir" >&2; exit 1; }
[[ -f "$APP" ]] || { echo "missing $APP" >&2; exit 1; }
[[ -f "$TIME/koollook-time.js" ]] || { echo "missing $TIME/koollook-time.js" >&2; exit 1; }

WIDGETS=(
  com.koollook.planisphere
  com.koollook.calendar
  com.koollook.weather
  com.koollook.sttclip
  com.koollook.audioviz
  com.koollook.muhurta
  com.koollook.hora
)

for id in "${WIDGETS[@]}"; do
  ui="$ROOT/plasmoids/$id/contents/ui"
  mkdir -p "$ui/org/koollook/glass" "$ui/org/koollook/location" "$ui/config"
  rm -rf "$ui/org/koollook/glass" "$ui/org/koollook/location"
  mkdir -p "$ui/org/koollook/glass" "$ui/org/koollook/location"
  cp -a "$GLASS"/. "$ui/org/koollook/glass/"
  cp -a "$LOC"/. "$ui/org/koollook/location/"
  cp -a "$APP" "$ui/config/ConfigAppearance.qml"
done

for id in com.koollook.muhurta com.koollook.hora; do
  ui="$ROOT/plasmoids/$id/contents/ui"
  mkdir -p "$ui/engine" "$ui/config"
  cp -a "$TIME/koollook-time.js" "$ui/engine/"
  cp -a "$TIME/TimeBoard.qml" "$ui/"
  cp -a "$TIME/ConfigLocation.qml" "$ui/config/ConfigGeneral.qml"
done

for site in muhurta hora; do
  mkdir -p "$ROOT/web/$site/css" "$ROOT/web/$site/js"
  cp -a "$TIME/koollook.css" "$ROOT/web/$site/css/"
  cp -a "$TIME/koollook-time.js" "$ROOT/web/$site/js/"
  cp -a "$TIME/page.js" "$ROOT/web/$site/js/"
done
