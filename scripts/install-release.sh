#!/usr/bin/env bash
# Install a Koollook GitHub-release dir on this machine (~/.local, Plasma 6, no root).
# With no args and a TTY: interactive picker. Flags skip the menu.
# Download only the piece tarballs you want, or the suite bundle (all of them).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SHARE="${XDG_DATA_HOME:-$HOME/.local/share}"
shopt -s nullglob

usage() {
  cat <<'U'
Usage: ./install.sh [options]

  --all              every widget + theme piece + wallpapers + SDDM + Plymouth + STT
  --planisphere      Koollook Planisphere
  --calendar         Koollook Calendar
  --weather          Koollook Weather
  --sttclip          Koollook STT Clip
  --stt-tray         Koollook STT tray
  --wavebar          Koollook Wavebar
  --muhurta          Koollook Muhurta
  --hora             Koollook Hora
  --theme            colors, icons, Koollook title bar, splash, default wallpaper
  --colors           color schemes
  --icons            griffin icon theme
  --titlebar         KoollooK title bar
  --aurorae          same as --titlebar (KWin engine name; kept as alias)
  --dotted           Koollook Dotted title bar (KDE 2 stipple)
  --splash           Plasma splash (KoollooK wordmark)
  --sddm             login theme
  --plymouth         boot splash (needs root for /usr/share/plymouth)
  --wallpaper        default griffin wallpaper
  --wallpaper-1 .. --wallpaper-7
  --stt              STT helper (koollook-stt)
  --apply            also switch this session to Koollook colors/icons/Koollook bar
  -h, --help         this text

No options + terminal: ask which pieces to install.
Each piece is its own tarball (or .plasmoid). Missing files are skipped with an error.
U
}

WANT_PLANISPHERE=0
WANT_CALENDAR=0
WANT_WEATHER=0
WANT_STTCLIP=0
WANT_STTTRAY=0
WANT_WAVEBAR=0
WANT_MUHURTA=0
WANT_HORA=0
WANT_COLORS=0
WANT_ICONS=0
WANT_AURORAE=0
WANT_DOTTED=0
WANT_SPLASH=0
WANT_SDDM=0
WANT_PLYMOUTH=0
WANT_WP=()
WANT_STT=0
WANT_APPLY=0
ANY_FLAG=0

want_theme_core() {
  WANT_COLORS=1 WANT_ICONS=1 WANT_AURORAE=1 WANT_SPLASH=1
  WANT_WP+=(default)
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --all)
      WANT_PLANISPHERE=1 WANT_CALENDAR=1 WANT_WEATHER=1
      WANT_STTCLIP=1 WANT_STTTRAY=1 WANT_WAVEBAR=1
      WANT_MUHURTA=1 WANT_HORA=1
      want_theme_core
      WANT_DOTTED=1 WANT_SDDM=1 WANT_PLYMOUTH=1 WANT_STT=1
      WANT_WP+=(1 2 3 4 5 6 7)
      ANY_FLAG=1
      ;;
    --planisphere) WANT_PLANISPHERE=1; ANY_FLAG=1 ;;
    --calendar) WANT_CALENDAR=1; ANY_FLAG=1 ;;
    --weather) WANT_WEATHER=1; ANY_FLAG=1 ;;
    --sttclip) WANT_STTCLIP=1; ANY_FLAG=1 ;;
    --stt-tray) WANT_STTTRAY=1; ANY_FLAG=1 ;;
    --wavebar) WANT_WAVEBAR=1; ANY_FLAG=1 ;;
    --muhurta) WANT_MUHURTA=1; ANY_FLAG=1 ;;
    --hora) WANT_HORA=1; ANY_FLAG=1 ;;
    --theme) want_theme_core; ANY_FLAG=1 ;;
    --colors) WANT_COLORS=1; ANY_FLAG=1 ;;
    --icons) WANT_ICONS=1; ANY_FLAG=1 ;;
    --aurorae) WANT_AURORAE=1; ANY_FLAG=1 ;;
    --dotted) WANT_DOTTED=1; ANY_FLAG=1 ;;
    --splash) WANT_SPLASH=1; ANY_FLAG=1 ;;
    --sddm) WANT_SDDM=1; ANY_FLAG=1 ;;
    --plymouth) WANT_PLYMOUTH=1; ANY_FLAG=1 ;;
    --wallpaper) WANT_WP+=(default); ANY_FLAG=1 ;;
    --wallpaper-[1-7]) WANT_WP+=("${1#--wallpaper-}"); ANY_FLAG=1 ;;
    --stt) WANT_STT=1; ANY_FLAG=1 ;;
    --apply) WANT_APPLY=1; ANY_FLAG=1 ;;
    *) echo "unknown option: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

ask_yn() {
  local prompt="$1" def="${2:-n}" ans
  if [[ "$def" == y ]]; then
    read -r -p "$prompt [Y/n] " ans || true
    [[ -z "$ans" || "$ans" =~ ^[Yy] ]]
  else
    read -r -p "$prompt [y/N] " ans || true
    [[ "$ans" =~ ^[Yy] ]]
  fi
}

if [[ "$ANY_FLAG" -eq 0 ]]; then
  if [[ -t 0 ]]; then
    echo "Koollook tester install — choose pieces (default No)."
    echo
    ask_yn "Planisphere (local sky)?" n && WANT_PLANISPHERE=1
    ask_yn "Calendar?" n && WANT_CALENDAR=1
    ask_yn "Weather?" n && WANT_WEATHER=1
    ask_yn "Muhurta?" n && WANT_MUHURTA=1
    ask_yn "Hora?" n && WANT_HORA=1
    ask_yn "STT Clip widget?" n && WANT_STTCLIP=1
    ask_yn "STT tray applet?" n && WANT_STTTRAY=1
    ask_yn "Wavebar?" n && WANT_WAVEBAR=1
    ask_yn "Color schemes?" n && WANT_COLORS=1
    ask_yn "Icons?" n && WANT_ICONS=1
    ask_yn "Koollook title bar?" n && WANT_AURORAE=1
    ask_yn "Koollook Dotted title bar?" n && WANT_DOTTED=1
    ask_yn "Plasma splash (KoollooK)?" n && WANT_SPLASH=1
    ask_yn "Default wallpaper?" n && WANT_WP+=(default)
    ask_yn "Extra wallpapers 1–7 (large)?" n && WANT_WP+=(1 2 3 4 5 6 7)
    ask_yn "SDDM login theme?" n && WANT_SDDM=1
    ask_yn "Plymouth boot splash (needs root)?" n && WANT_PLYMOUTH=1
    ask_yn "STT helper (koollook-stt)?" n && WANT_STT=1
    ask_yn "Apply Koollook colors/icons/Koollook bar to this session now?" n && WANT_APPLY=1
    echo
  else
    echo "No TTY. Pass --all or component flags. Try --help." >&2
    exit 2
  fi
fi

selected=0
for v in "$WANT_PLANISPHERE" "$WANT_CALENDAR" "$WANT_WEATHER" "$WANT_MUHURTA" \
         "$WANT_HORA" "$WANT_STTCLIP" "$WANT_STTTRAY" "$WANT_WAVEBAR" \
         "$WANT_COLORS" "$WANT_ICONS" "$WANT_AURORAE" "$WANT_DOTTED" \
         "$WANT_SPLASH" "$WANT_SDDM" "$WANT_PLYMOUTH" "$WANT_STT"; do
  [[ "$v" -eq 1 ]] && selected=1
done
[[ ${#WANT_WP[@]} -gt 0 ]] && selected=1
if [[ "$selected" -eq 0 ]]; then
  echo "Nothing selected. Use --all or pick at least one piece. Try --help."
  exit 0
fi

install_plasmoid() {
  local needle="$1" f
  for f in "$HERE"/com.koollook.${needle}-*.plasmoid; do
    echo "widget: $(basename "$f")"
    kpackagetool6 -t Plasma/Applet -u "$f" 2>/dev/null || kpackagetool6 -t Plasma/Applet -i "$f"
    return 0
  done
  echo "missing plasmoid matching $needle" >&2
  return 1
}

STAGING=""
ensure_staging() {
  [[ -n "$STAGING" ]] && return 0
  STAGING="$(mktemp -d)"
}

cleanup() {
  [[ -n "$STAGING" && -d "$STAGING" ]] && rm -rf "$STAGING"
}
trap cleanup EXIT

# Match PREFIX-VERSION.tar.zst but not PREFIX-N-VERSION.tar.zst (wallpaper extras).
find_tarball() {
  local prefix="$1" f base rest
  for f in "$HERE"/${prefix}-*.tar.zst; do
    [[ -f "$f" ]] || continue
    base="$(basename "$f" .tar.zst)"
    rest="${base#${prefix}-}"
    if [[ "$rest" =~ ^[0-9]+\.[0-9]+ ]]; then
      printf '%s\n' "$f"
      return 0
    fi
  done
  return 1
}

extract_piece() {
  local prefix="$1" f
  f="$(find_tarball "$prefix")" || { echo "missing ${prefix}-<ver>.tar.zst" >&2; return 1; }
  ensure_staging
  echo "unpack: $(basename "$f")"
  tar -C "$STAGING" -xf "$f"
}

[[ "$WANT_PLANISPHERE" -eq 1 ]] && install_plasmoid planisphere
[[ "$WANT_CALENDAR" -eq 1 ]] && install_plasmoid calendar
[[ "$WANT_WEATHER" -eq 1 ]] && install_plasmoid weather
[[ "$WANT_MUHURTA" -eq 1 ]] && install_plasmoid muhurta
[[ "$WANT_HORA" -eq 1 ]] && install_plasmoid hora
[[ "$WANT_STTCLIP" -eq 1 ]] && install_plasmoid sttclip
[[ "$WANT_STTTRAY" -eq 1 ]] && install_plasmoid stt
[[ "$WANT_WAVEBAR" -eq 1 ]] && install_plasmoid audioviz

if [[ "$WANT_COLORS" -eq 1 ]]; then
  extract_piece koollook-colors
  mkdir -p "$SHARE/color-schemes"
  cp -a "$STAGING/theme/color-schemes/"*.colors "$SHARE/color-schemes/"
  echo "theme: color schemes"
fi
if [[ "$WANT_ICONS" -eq 1 ]]; then
  extract_piece koollook-icons
  mkdir -p "$SHARE/icons"
  rm -rf "$SHARE/icons/Koollook"
  cp -a "$STAGING/theme/icons/Koollook" "$SHARE/icons/Koollook"
  echo "theme: icons"
fi
if [[ "$WANT_AURORAE" -eq 1 ]]; then
  extract_piece koollook-aurorae
  mkdir -p "$SHARE/aurorae/themes" "$SHARE/kwin/aurorae"
  rm -rf "$SHARE/aurorae/themes/Koollook"
  cp -a "$STAGING/theme/window-decoration/Koollook" "$SHARE/aurorae/themes/Koollook"
  if [[ -d "$STAGING/theme/kwin-aurorae" ]]; then
    cp -a "$STAGING/theme/kwin-aurorae/"*.qml "$SHARE/kwin/aurorae/" 2>/dev/null || true
  fi
  echo "theme: Koollook title bar"
fi
if [[ "$WANT_DOTTED" -eq 1 ]]; then
  extract_piece koollook-dotted
  mkdir -p "$SHARE/kwin/decorations" "$SHARE/aurorae/themes"
  rm -rf "$SHARE/kwin/decorations/org.koollook.dotted"
  cp -a "$STAGING/theme/window-decoration/org.koollook.dotted" "$SHARE/kwin/decorations/org.koollook.dotted"
  if [[ -d "$STAGING/theme/window-decoration/KoollookDotted" ]]; then
    rm -rf "$SHARE/aurorae/themes/KoollookDotted"
    cp -a "$STAGING/theme/window-decoration/KoollookDotted" "$SHARE/aurorae/themes/KoollookDotted"
  fi
  echo "theme: Koollook Dotted title bar"
fi
if [[ "$WANT_SPLASH" -eq 1 ]]; then
  extract_piece koollook-splash
  mkdir -p "$SHARE/plasma/look-and-feel"
  rm -rf "$SHARE/plasma/look-and-feel/org.koollook.desktop"
  cp -a "$STAGING/theme/look-and-feel/org.koollook.desktop" "$SHARE/plasma/look-and-feel/"
  echo "theme: Plasma splash (KoollooK)"
fi
if [[ "$WANT_SDDM" -eq 1 ]]; then
  extract_piece koollook-sddm
  mkdir -p "$SHARE/sddm/themes"
  rm -rf "$SHARE/sddm/themes/Koollook"
  cp -a "$STAGING/theme/sddm/Koollook" "$SHARE/sddm/themes/Koollook"
  echo "theme: SDDM (also copy to /usr/share/sddm/themes if the greeter is system-wide)"
fi

mkdir -p "$SHARE/wallpapers"
for wp in "${WANT_WP[@]+"${WANT_WP[@]}"}"; do
  if [[ "$wp" == default ]]; then
    extract_piece koollook-wallpaper || continue
  else
    extract_piece "koollook-wallpaper-${wp}" || continue
  fi
  for d in "$STAGING"/theme/wallpapers/*; do
    [[ -d "$d" ]] || continue
    name="$(basename "$d")"
    rm -rf "$SHARE/wallpapers/$name"
    cp -a "$d" "$SHARE/wallpapers/$name"
    echo "wallpaper: $name"
  done
done

if [[ "$WANT_PLYMOUTH" -eq 1 ]]; then
  extract_piece koollook-plymouth
  mkdir -p "$SHARE/plymouth/themes"
  rm -rf "$SHARE/plymouth/themes/koollook"
  cp -a "$STAGING/theme/plymouth/koollook" "$SHARE/plymouth/themes/koollook"
  ply="$STAGING/theme/plymouth/install.sh"
  if [[ -x "$ply" ]] && [[ -w /usr/share/plymouth/themes ]]; then
    "$ply"
  else
    echo "plymouth: copied to $SHARE/plymouth/themes/koollook"
    echo "  system install: sudo bash -c 'cp -a \"$SHARE/plymouth/themes/koollook\" /usr/share/plymouth/themes/ && plymouth-set-default-theme koollook'"
  fi
fi

if [[ "$WANT_STT" -eq 1 ]]; then
  if extract_piece koollook-accessibility; then
    (cd "$STAGING" && ./accessibility/koollook-stt/install.sh)
  fi
fi

if [[ "$WANT_APPLY" -eq 1 ]]; then
  echo "applying Koollook look to this session"
  command -v plasma-apply-colorscheme >/dev/null && plasma-apply-colorscheme Koollook >/dev/null || true
  command -v plasma-apply-icontheme >/dev/null && plasma-apply-icontheme Koollook >/dev/null || true
  kwriteconfig6 --file kdeglobals --group General --key ColorScheme Koollook
  kwriteconfig6 --file kdeglobals --group Icons --key Theme Koollook
  kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae.v2
  kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme '__aurorae__svg__Koollook'
  if [[ "$WANT_SPLASH" -eq 1 ]]; then
    kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML
    kwriteconfig6 --file ksplashrc --group KSplash --key Theme org.koollook.desktop
  fi
  if command -v qdbus6 >/dev/null; then
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
  fi
fi

echo
echo "Done for $USER."
echo "Restart Plasma if needed:  kquitapp6 plasmashell; kstart plasmashell"
echo "Add Widgets → search Koollook.  Window Decorations → Koollook or Koollook Dotted."
