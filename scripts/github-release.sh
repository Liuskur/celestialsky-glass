#!/usr/bin/env bash
# Create a GitHub Release (draft) from dist/ after scripts/package.sh.
# Requires: gh auth, git push of this commit (or pass --target).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
VER="$(tr -d '[:space:]' < "$ROOT/VERSION")"
TAG="v${VER}"
REPO="${GITHUB_REPO:-Liuskur/celestialsky-glass}"
NOTES="$DIST/RELEASE-NOTES.md"
[[ -f "$NOTES" ]] || NOTES="$ROOT/RELEASE-NOTES.md"
[[ -f "$DIST/koollook-${VER}.tar.zst" ]] || { echo "run scripts/package.sh first" >&2; exit 1; }

args=(
  "$TAG"
  --repo "$REPO"
  --title "Koollook ${VER} (tester)"
  --notes-file "$NOTES"
  --draft
)
[[ -n "${GITHUB_TARGET:-}" ]] && args+=(--target "$GITHUB_TARGET")

files=(
  "$DIST/koollook-${VER}.tar.zst"
  "$DIST/koollook-theme-${VER}.tar.zst"
  "$DIST/koollook-widgets-${VER}.tar.zst"
  "$DIST/koollook-accessibility-${VER}.tar.zst"
  "$DIST/SHA256SUMS"
)
shopt -s nullglob
files+=("$DIST"/com.koollook.*.plasmoid)

echo "gh release create ${args[*]}"
echo "assets:"
printf '  %s\n' "${files[@]}"
gh release create "${args[@]}" "${files[@]}"
echo "Draft: https://github.com/${REPO}/releases"
echo "Push the git tag/commit if GitHub cannot see this SHA, then edit the draft and Publish."
