#!/usr/bin/env bash
# Package and install all Koollook Plasma applets, theme, and STT.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)/.."
ROOT="$(cd "$ROOT" && pwd)"
"$ROOT/scripts/package.sh"
for f in "$ROOT/dist"/com.koollook.*.plasmoid; do
  kpackagetool6 -t Plasma/Applet -u "$f" 2>/dev/null || kpackagetool6 -t Plasma/Applet -i "$f"
done
"$ROOT/theme/install.sh"
"$ROOT/accessibility/koollook-stt/install.sh"

python3 - <<'PY'
from pathlib import Path
plugin = "com.koollook.stt"
p = Path.home() / ".config/plasma-org.kde.plasma.desktop-appletsrc"
if not p.is_file():
    raise SystemExit(0)
text = p.read_text()
out = []
changed = False
for line in text.splitlines(True):
    raw = line.rstrip("\n")
    key = None
    for k in ("extraItems", "knownItems", "hiddenItems"):
        if raw.startswith(k + "="):
            key = k
            break
    if key is None:
        out.append(line)
        continue
    items = [x for x in raw.split("=", 1)[1].split(",") if x]
    if key == "hiddenItems":
        if plugin in items:
            items = [x for x in items if x != plugin]
            changed = True
    elif plugin not in items:
        items.append(plugin)
        changed = True
    out.append(key + "=" + ",".join(items) + "\n")
if changed:
    p.write_text("".join(out))
    print("system tray: enabled", plugin)
PY

echo "Koollook widgets, theme, and STT updated locally."
echo "STT tray: com.koollook.stt (middle-click toggle). Restart plasmashell if the icon is missing."
