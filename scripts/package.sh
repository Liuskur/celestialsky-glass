#!/usr/bin/env bash
# Build Koollook plasmoids, one tarball per piece, and one suite bundle.
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

pack_zst() {
  local out="$1"
  shift
  rm -f "$out"
  tar -C "$ROOT" \
    --exclude 'theme/window-decoration/kdecoration-kde2/build' \
    --exclude 'theme/window-decoration/kdecoration-kde2/.git' \
    -c "$@" | zstd -19 -o "$out"
  echo "wrote $out"
}

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
package_one com.koollook.muhurta
package_one com.koollook.hora

pack_zst "$DIST/koollook-colors-${SUITE_VER}.tar.zst" theme/color-schemes
pack_zst "$DIST/koollook-icons-${SUITE_VER}.tar.zst" theme/icons/Koollook
pack_zst "$DIST/koollook-plasma-${SUITE_VER}.tar.zst" theme/plasma/desktoptheme/Koollook
pack_zst "$DIST/koollook-titlebar-${SUITE_VER}.tar.zst" \
  theme/window-decoration/Koollook theme/kwin-aurorae theme/kwin
pack_zst "$DIST/koollook-dotted-${SUITE_VER}.tar.zst" \
  theme/window-decoration/KoollookDotted \
  theme/window-decoration/org.koollook.dotted \
  theme/window-decoration/kdecoration-kde2
pack_zst "$DIST/koollook-splash-${SUITE_VER}.tar.zst" theme/look-and-feel
pack_zst "$DIST/koollook-sddm-${SUITE_VER}.tar.zst" theme/sddm
pack_zst "$DIST/koollook-plymouth-${SUITE_VER}.tar.zst" theme/plymouth

for d in "$ROOT"/theme/wallpapers/*; do
  [[ -d "$d" ]] || continue
  name="$(basename "$d")"
  if [[ "$name" == "Koollook" ]]; then
    pack_zst "$DIST/koollook-wallpaper-${SUITE_VER}.tar.zst" "theme/wallpapers/$name"
  elif [[ "$name" =~ ^Koollook-([0-9]+)$ ]]; then
    pack_zst "$DIST/koollook-wallpaper-${BASH_REMATCH[1]}-${SUITE_VER}.tar.zst" "theme/wallpapers/$name"
  else
    pack_zst "$DIST/koollook-wallpaper-${name}-${SUITE_VER}.tar.zst" "theme/wallpapers/$name"
  fi
done

pack_zst "$DIST/koollook-accessibility-${SUITE_VER}.tar.zst" accessibility

cp -a "$ROOT/README.md" "$DIST/README.md"
cp -a "$ROOT/LICENSE" "$DIST/LICENSE"
cp -a "$ROOT/TESTERS.md" "$DIST/TESTERS.md"
cp -a "$ROOT/RELEASE-NOTES.md" "$DIST/RELEASE-NOTES.md"
cp -a "$ROOT/scripts/install-release.sh" "$DIST/install.sh"
chmod 755 "$DIST/install.sh"

(
  cd "$DIST"
  sha256sum -- com.koollook*.plasmoid koollook-*.tar.zst \
    README.md LICENSE TESTERS.md RELEASE-NOTES.md install.sh > SHA256SUMS
)

STAGE="$(mktemp -d)"
mkdir -p "$STAGE/koollook-${SUITE_VER}"
cp -a "$DIST"/com.koollook*.plasmoid "$DIST"/koollook-*.tar.zst \
  "$DIST/README.md" "$DIST/LICENSE" "$DIST/TESTERS.md" "$DIST/RELEASE-NOTES.md" \
  "$DIST/install.sh" "$DIST/SHA256SUMS" \
  "$STAGE/koollook-${SUITE_VER}/"
ARCHIVE="$DIST/koollook-${SUITE_VER}.tar.zst"
rm -f "$ARCHIVE"
tar -C "$STAGE" -c "koollook-${SUITE_VER}" | zstd -19 -o "$ARCHIVE"
rm -rf "$STAGE"
echo "wrote $ARCHIVE"
(
  cd "$DIST"
  sha256sum -- "koollook-${SUITE_VER}.tar.zst" >> SHA256SUMS
)
ls -1 "$DIST"
