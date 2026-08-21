#!/usr/bin/env bash
# Build every Koollook release artifact and copy it into ./release
# (per-piece tarballs, plasmoids, install.sh, checksums, suite bundle).
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
echo "ship bundle:  $OUT/koollook-${VER}.tar.zst"
echo "or download only the piece tarballs / .plasmoid files next to install.sh"
