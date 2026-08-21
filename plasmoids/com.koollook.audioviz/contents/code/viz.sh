#!/usr/bin/env bash
# PipeWire/Pulse PCM → bar heights for Koollook Wavebar (Plasma 6).
# Args: --mode mic|output  --bars N  --sensitivity PCT
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

src=""
if command -v pactl >/dev/null; then
  if [[ "$MODE" == "mic" ]]; then
    src="$(pactl get-default-source 2>/dev/null || true)"
  else
    local_sink="$(pactl get-default-sink 2>/dev/null || true)"
    [[ -n "$local_sink" ]] && src="${local_sink}.monitor"
  fi
fi

rec=(parec --raw --rate=16000 --channels=1 --format=s16le)
[[ -n "$src" ]] && rec+=(-d "$src")

exec "${rec[@]}" 2>/dev/null | python3 - "$BARS" "$SENS" <<'PY'
import sys, struct, math
bars = int(sys.argv[1])
sens = max(1, int(sys.argv[2])) / 25.0
chunk = 1024
while True:
    b = sys.stdin.buffer.read(chunk * 2)
    if not b:
        break
    n = len(b) // 2
    samp = struct.unpack("<" + str(n) + "h", b[: n * 2])
    step = max(1, n // bars)
    vals = []
    for i in range(bars):
        sl = samp[i * step : (i + 1) * step]
        if not sl:
            vals.append(0.0)
            continue
        rms = math.sqrt(sum(x * x for x in sl) / len(sl)) / 32768.0
        vals.append(min(1.0, rms * sens))
    sys.stdout.write(" ".join("%.3f" % v for v in vals) + "\n")
    sys.stdout.flush()
PY
