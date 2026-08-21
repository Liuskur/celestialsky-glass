#!/usr/bin/env bash
# Install a Koollook GitHub-release dir on this machine (~/.local, Plasma 6, no root).
# With no args and a TTY: interactive picker. Flags skip the menu.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SHARE="${XDG_DATA_HOME:-$HOME/.local/share}"
shopt -s nullglob

usage() {
  cat <<'U'
Usage: ./install.sh [options]

  --all              widgets + theme + dotted + STT helper
  --planisphere      Koollook Planisphere
  --calendar         Koollook Calendar
  --weather          Koollook Weather
  --sttclip          Koollook STT Clip
  --stt-tray         Koollook STT tray
  --wavebar          Koollook Wavebar
  --muhurta          Koollook Muhurta
  --hora             Koollook Hora
  --theme            colors, icons, Koollook title bar
  --dotted           Koollook Dotted title bar (KDE 2 stipple)
  --stt              STT helper (koollook-stt)
  --apply            also switch this session to Koollook colors/icons/Koollook bar
  -h, --help         this text

No options + terminal: ask which pieces to install.
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
WANT_THEME=0
WANT_DOTTED=0
WANT_STT=0
WANT_APPLY=0
ANY_FLAG=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --all)
      WANT_PLANISPHERE=1 WANT_CALENDAR=1 WANT_WEATHER=1
      WANT_STTCLIP=1 WANT_STTTRAY=1 WANT_WAVEBAR=1
      WANT_MUHURTA=1 WANT_HORA=1
      WANT_THEME=1 WANT_DOTTED=1 WANT_STT=1
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
    --theme) WANT_THEME=1; ANY_FLAG=1 ;;
    --dotted) WANT_DOTTED=1; ANY_FLAG=1 ;;
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
    echo "Koollook tester install — choose pieces (default No except as noted)."
    echo
    ask_yn "Planisphere (local sky)?" n && WANT_PLANISPHERE=1
    ask_yn "Calendar?" n && WANT_CALENDAR=1
    ask_yn "Weather?" n && WANT_WEATHER=1
    ask_yn "Muhurta?" n && WANT_MUHURTA=1
    ask_yn "Hora?" n && WANT_HORA=1
    ask_yn "STT Clip widget?" n && WANT_STTCLIP=1
    ask_yn "STT tray applet?" n && WANT_STTTRAY=1
    ask_yn "Wavebar?" n && WANT_WAVEBAR=1
    ask_yn "Theme (colors, icons, Koollook title bar)?" n && WANT_THEME=1
    ask_yn "Koollook Dotted title bar?" n && WANT_DOTTED=1
    ask_yn "STT helper (koollook-stt)?" n && WANT_STT=1
    ask_yn "Apply Koollook colors/icons/Koollook bar to this session now?" n && WANT_APPLY=1
    echo
    if [[ "$WANT_PLANISPHERE$WANT_CALENDAR$WANT_WEATHER$WANT_MUHURTA$WANT_HORA$WANT_STTCLIP$WANT_STTTRAY$WANT_WAVEBAR$WANT_THEME$WANT_DOTTED$WANT_STT" == *1* ]]; then
      true
    else
      echo "Nothing selected. Use --all or pick at least one piece. Try --help."
      exit 0
    fi
  else
    echo "No TTY. Pass --all or component flags. Try --help." >&2
    exit 2
  fi
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

THEME_TMP=""
ensure_theme_tree() {
  [[ -n "$THEME_TMP" ]] && return 0
  local f
  f="$(echo "$HERE"/koollook-theme-*.tar.zst)"
  [[ -f "$f" ]] || { echo "missing koollook-theme-*.tar.zst" >&2; return 1; }
  THEME_TMP="$(mktemp -d)"
  tar -C "$THEME_TMP" -xf "$f"
}

cleanup() {
  [[ -n "$THEME_TMP" && -d "$THEME_TMP" ]] && rm -rf "$THEME_TMP"
}
trap cleanup EXIT

[[ "$WANT_PLANISPHERE" -eq 1 ]] && install_plasmoid planisphere
[[ "$WANT_CALENDAR" -eq 1 ]] && install_plasmoid calendar
[[ "$WANT_WEATHER" -eq 1 ]] && install_plasmoid weather
[[ "$WANT_MUHURTA" -eq 1 ]] && install_plasmoid muhurta
[[ "$WANT_HORA" -eq 1 ]] && install_plasmoid hora
[[ "$WANT_STTCLIP" -eq 1 ]] && install_plasmoid sttclip
[[ "$WANT_STTTRAY" -eq 1 ]] && install_plasmoid stt
[[ "$WANT_WAVEBAR" -eq 1 ]] && install_plasmoid audioviz

if [[ "$WANT_THEME" -eq 1 || "$WANT_DOTTED" -eq 1 ]]; then
  ensure_theme_tree
  ROOT="$THEME_TMP"
  mkdir -p "$SHARE/color-schemes" "$SHARE/aurorae/themes" "$SHARE/plasma/look-and-feel" "$SHARE/icons"
  if [[ "$WANT_THEME" -eq 1 ]]; then
    echo "theme: colors, icons, Koollook title bar"
    cp -a "$ROOT/theme/color-schemes/"*.colors "$SHARE/color-schemes/"
    rm -rf "$SHARE/aurorae/themes/Koollook"
    cp -a "$ROOT/theme/window-decoration/Koollook" "$SHARE/aurorae/themes/Koollook"
    rm -rf "$SHARE/plasma/look-and-feel/org.koollook.desktop"
    cp -a "$ROOT/theme/look-and-feel/org.koollook.desktop" "$SHARE/plasma/look-and-feel/"
    rm -rf "$SHARE/icons/Koollook"
    cp -a "$ROOT/theme/icons/Koollook" "$SHARE/icons/Koollook"
  fi
  if [[ "$WANT_DOTTED" -eq 1 ]]; then
    echo "theme: Koollook Dotted title bar"
    rm -rf "$SHARE/aurorae/themes/KoollookDotted"
    mkdir -p "$SHARE/kwin/decorations"
    rm -rf "$SHARE/kwin/decorations/org.koollook.dotted"
    cp -a "$ROOT/theme/window-decoration/org.koollook.dotted" "$SHARE/kwin/decorations/org.koollook.dotted"
  fi
fi

if [[ "$WANT_STT" -eq 1 ]]; then
  f="$(echo "$HERE"/koollook-accessibility-*.tar.zst)"
  if [[ -f "$f" ]]; then
    tmp="$(mktemp -d)"
    tar -C "$tmp" -xf "$f"
    (cd "$tmp" && ./accessibility/koollook-stt/install.sh)
    rm -rf "$tmp"
  else
    echo "missing koollook-accessibility-*.tar.zst" >&2
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
  if command -v qdbus6 >/dev/null; then
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
  fi
fi

echo
echo "Done for $USER."
echo "Restart Plasma if needed:  kquitapp6 plasmashell; kstart plasmashell"
echo "Add Widgets → search Koollook.  Window Decorations → Koollook or Koollook Dotted."
