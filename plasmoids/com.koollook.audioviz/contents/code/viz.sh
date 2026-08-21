#!/usr/bin/env bash
# PipeWire/Pulse PCM → bar heights for Koollook Wavebar (Plasma 6).
set -euo pipefail
MODE="output"
BARS=48
SENS=40
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) MODE="${2:-output}"; shift 2 ;;
    --bars) BARS="${2:-48}"; shift 2 ;;
    --sensitivity) SENS="${2:-40}"; shift 2 ;;
    *) shift ;;
  esac
done
HERE="$(cd "$(dirname "$0")" && pwd)"
src=""
if command -v pactl >/dev/null; then
  if [[ "$MODE" == "mic" ]]; then
    src="$(pactl get-default-source 2>/dev/null || true)"
  else
    sink="$(pactl get-default-sink 2>/dev/null || true)"
    [[ -n "$sink" ]] && src="${sink}.monitor"
  fi
fi
rec=(parec --raw --rate=16000 --channels=1 --format=s16le)
[[ -n "$src" ]] && rec+=(-d "$src")
exec "${rec[@]}" 2>/dev/null | python3 "$HERE/viz.py" "$BARS" "$SENS"
