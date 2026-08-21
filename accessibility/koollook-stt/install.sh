#!/usr/bin/env bash
# Install Koollook STT toggle + optional KDE Connect Run Command entries.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$ROOT/accessibility/koollook-stt"
BINDIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
APPDIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
KDECONNECT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kdeconnect"

mkdir -p "$BINDIR" "$APPDIR"
install -m 0755 "$SRC/koollook-stt" "$BINDIR/koollook-stt"
install -m 0755 "$SRC/koollook-stt-toggle" "$BINDIR/koollook-stt-toggle"
install -m 0644 "$SRC/koollook-stt.desktop" "$APPDIR/koollook-stt.desktop"
# desktop Exec must be on PATH
sed -i "s|^Exec=.*|Exec=$BINDIR/koollook-stt --toggle|" "$APPDIR/koollook-stt.desktop"
command -v update-desktop-database >/dev/null && update-desktop-database "$APPDIR" >/dev/null 2>&1 || true

merge_runcommand() {
  local cfg="$1"
  [[ -f "$cfg" ]] || return 0
  python3 - "$cfg" "$BINDIR" <<'PY'
import json, re, sys, uuid
from pathlib import Path
cfg_path, bindir = Path(sys.argv[1]), sys.argv[2]
text = cfg_path.read_text()
m = re.search(r'(?m)^commands=(.*)$', text)
if not m:
    sys.exit(0)
raw = m.group(1).strip()
if raw.startswith('"') and raw.endswith('"'):
    raw = raw[1:-1]
try:
    data = json.loads(bytes(raw, "utf-8").decode("unicode_escape"))
except json.JSONDecodeError:
    sys.exit(0)
wanted = {
    "koollook-stt-toggle": {
        "name": "Koollook STT toggle",
        "command": f"{bindir}/koollook-stt --toggle",
    },
    "koollook-stt-start": {
        "name": "Koollook STT start",
        "command": f"{bindir}/koollook-stt --start",
    },
    "koollook-stt-stop": {
        "name": "Koollook STT stop",
        "command": f"{bindir}/koollook-stt --stop",
    },
}
existing_names = {v.get("name") for v in data.values()}
for key, spec in wanted.items():
    if spec["name"] in existing_names:
        continue
    data[str(uuid.uuid4())] = spec
enc = json.dumps(data, separators=(",", ":"))
kenc = enc.replace("\\", "\\\\").replace('"', '\\"')
new = re.sub(r'(?m)^commands=.*$', 'commands="' + kenc + '"', text, count=1)
cfg_path.write_text(new)
PY
}

if [[ -d "$KDECONNECT_DIR" ]]; then
  find "$KDECONNECT_DIR" -path '*/kdeconnect_runcommand/config' -type f | while read -r c; do
    merge_runcommand "$c"
  done
fi

echo "Installed $BINDIR/koollook-stt"
echo "Shortcut: Meta+Alt+V (assign in System Settings if needed)"
echo "KDE Connect: phone Run Command → Koollook STT toggle"
echo "Phone as mic: set KOOLLOOK_STT_SOURCE=auto (uses a kdeconnect Pulse source when present)"
