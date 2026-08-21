#!/usr/bin/env bash
# Build every Koollook release artifact and copy it into ./release
# (plasmoids, theme/widgets/accessibility tarballs, install.sh, checksums, suite archive).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="$(tr -d '[:space:]' < "$ROOT/VERSION")"
OUT="$ROOT/release"

"$ROOT/scripts/package.sh"

rm -rf "$OUT"
mkdir -p "$OUT"
cp -a "$ROOT/dist"/. "$OUT/"

echo "assembled $OUT  (suite $VER)"
ls -lh "$OUT"
echo
echo "ship:  $OUT/koollook-${VER}.tar.zst"
echo "or:    $OUT/install.sh  plus the tarballs next to it"
