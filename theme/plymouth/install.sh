#!/usr/bin/env bash
# System Plymouth theme (needs write to /usr/share/plymouth).
set -euo pipefail
SRC="$(cd "$(dirname "$0")/koollook" && pwd)"
DEST=/usr/share/plymouth/themes/koollook
echo "Installing Plymouth theme to $DEST"
mkdir -p "$DEST"
cp -a "$SRC"/. "$DEST/"
if command -v plymouth-set-default-theme >/dev/null; then
  plymouth-set-default-theme koollook
  command -v mkinitcpio >/dev/null && mkinitcpio -P || true
  command -v update-initramfs >/dev/null && update-initramfs -u || true
fi
echo "Plymouth theme Koollook installed."
