#!/usr/bin/env bash
# Build Koollook plasmoids, theme, STT helper, and a distro/store archive.
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

package_one com.koollook.planisphere
package_one com.koollook.calendar
package_one com.koollook.weather
package_one com.koollook.sttclip
package_one com.koollook.stt
package_one com.koollook.audioviz
# --- three product packs ---
tar -C "$ROOT" --exclude 'theme/window-decoration/kdecoration-kde2/build' -c theme \
  | zstd -19 -o "$DIST/koollook-theme-${SUITE_VER}.tar.zst"
echo "wrote $DIST/koollook-theme-${SUITE_VER}.tar.zst"

WID="$DIST/stage-widgets"
mkdir -p "$WID"
cp -a "$DIST"/com.koollook.*.plasmoid "$WID"/
cp -a "$ROOT/LICENSE" "$ROOT/README.md" "$WID"/
tar -C "$WID" -c . | zstd -19 -o "$DIST/koollook-widgets-${SUITE_VER}.tar.zst"
rm -rf "$WID"
echo "wrote $DIST/koollook-widgets-${SUITE_VER}.tar.zst"

tar -C "$ROOT" -c accessibility \
  | zstd -19 -o "$DIST/koollook-accessibility-${SUITE_VER}.tar.zst"
echo "wrote $DIST/koollook-accessibility-${SUITE_VER}.tar.zst"

cp -a "$ROOT/README.md" "$DIST/README.md"
cp -a "$ROOT/LICENSE" "$DIST/LICENSE"
cp -a "$ROOT/TESTERS.md" "$DIST/TESTERS.md"
cp -a "$ROOT/RELEASE-NOTES.md" "$DIST/RELEASE-NOTES.md"
cp -a "$ROOT/scripts/install-release.sh" "$DIST/install.sh"
chmod 755 "$DIST/install.sh"

(
  cd "$DIST"
  sha256sum -- com.koollook*.plasmoid koollook-theme-*.tar.zst koollook-widgets-*.tar.zst \
    koollook-accessibility-*.tar.zst README.md LICENSE TESTERS.md RELEASE-NOTES.md install.sh > SHA256SUMS
)

STAGE="$(mktemp -d)"
mkdir -p "$STAGE/koollook-${SUITE_VER}"
cp -a "$DIST"/com.koollook*.plasmoid "$DIST"/koollook-theme-*.tar.zst \
  "$DIST"/koollook-widgets-*.tar.zst "$DIST"/koollook-accessibility-*.tar.zst \
  "$DIST/README.md" "$DIST/LICENSE" "$DIST/TESTERS.md" "$DIST/RELEASE-NOTES.md" \
  "$DIST/install.sh" "$DIST/SHA256SUMS" \
  "$STAGE/koollook-${SUITE_VER}/"
ARCHIVE="$DIST/koollook-${SUITE_VER}.tar.zst"
rm -f "$ARCHIVE"
tar -C "$STAGE" -c "koollook-${SUITE_VER}" | zstd -19 -o "$ARCHIVE"
rm -rf "$STAGE"
echo "wrote $ARCHIVE"
ls -1 "$DIST"
