# Koollook STT (accessibility)

Local **English** speech-to-text into a **clip buffer** (`~/.local/state/koollook/clip.txt`).
The **Koollook STT Clip** desktop widget shows that buffer.

- Say **delete clip** — empty the buffer.
- Say **send clip** — type the buffer into the currently focused field (`wtype`), then clear the widget. If the compositor rejects virtual-keyboard, AT-SPI insert is used; clipboard is always filled as backup.

```bash
./accessibility/koollook-stt/install.sh
koollook-stt --toggle     # Meta+Alt+V
koollook-stt --list-sources
```

Phrases are configurable (`~/.config/koollook/stt.conf` or the widget Clip page).

Uses ResoNider **whisper.cpp** (`tiny.en`). Needs `wtype` (or ydotool/xdotool) to type on send.

## KDE Connect / phone mic

| `KOOLLOOK_STT_SOURCE` | Behaviour |
|------------------------|-----------|
| `auto` (default) | Source name containing `kdeconnect`, else default input |
| Pulse source name | That source |

`install.sh` adds Run Command: STT toggle / start / stop.
