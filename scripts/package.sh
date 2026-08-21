#!/usr/bin/env bash
# Build all Koollook widget .plasmoid packages plus a combined archive.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
SUITE_VER="$(tr -d '[:space:]' < "$ROOT/VERSION")"

if command -v 7z >/dev/null 2>&1; then
  zip_add() { 7z a -tzip -mx=9 "$1" "${@:2}" >/dev/null; }
elif command -v zip >/dev/null 2>&1; then
  zip_add() { zip -r -9 "$1" "${@:2}" >/dev/null; }
else
  echo "need 7z or zip" >&2
  exit 1
fi

"$ROOT/scripts/sync-shared.sh"

rm -rf "$DIST"
mkdir -p "$DIST"

package_one() {
  local id="$1"
  local dir="$ROOT/plasmoids/$id"
  local ver tmp out
  ver="$(sed -n 's/.*"Version": *"\([^"]*\)".*/\1/p' "$dir/metadata.json" | head -1)"
  [[ -n "$ver" ]] || { echo "no Version in $dir/metadata.json" >&2; exit 1; }
  tmp="$(mktemp -d)"
  cp -a "$dir"/. "$tmp/"
  cp -a "$ROOT/LICENSE" "$tmp/LICENSE"
  out="$DIST/${id}-${ver}.plasmoid"
  rm -f "$out"
  (
    cd "$tmp"
    zip_add "$out" metadata.json contents LICENSE
  )
  rm -rf "$tmp"
  echo "wrote $out"
}

package_one com.koollook.celestialsky
package_one com.koollook.calendar
package_one com.koollook.weather

cp -a "$ROOT/README.md" "$DIST/README.md"
cp -a "$ROOT/LICENSE" "$DIST/LICENSE"

(
  cd "$DIST"
  sha256sum -- *.plasmoid README.md LICENSE > SHA256SUMS
)

ARCHIVE="$DIST/koollook-widgets-${SUITE_VER}.tar.zst"
if command -v zstd >/dev/null 2>&1; then
  rm -f "$ARCHIVE"
  (
    cd "$DIST"
    tar -c \
      com.koollook.celestialsky-*.plasmoid \
      com.koollook.calendar-*.plasmoid \
      com.koollook.weather-*.plasmoid \
      SHA256SUMS README.md LICENSE
  ) | zstd -19 -o "$ARCHIVE"
else
  ARCHIVE="$DIST/koollook-widgets-${SUITE_VER}.tar.gz"
  rm -f "$ARCHIVE"
  (
    cd "$DIST"
    tar -czf "$ARCHIVE" \
      com.koollook.celestialsky-*.plasmoid \
      com.koollook.calendar-*.plasmoid \
      com.koollook.weather-*.plasmoid \
      SHA256SUMS README.md LICENSE
  )
fi
echo "wrote $ARCHIVE"
ls -1 "$DIST"
