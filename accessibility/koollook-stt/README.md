# Koollook STT (accessibility)

The **Koollook STT** system tray applet starts/stops listening. The **Koollook STT Clip** desktop widget shows the buffer.

- Tray: left-click popup, middle-click toggle, right-click Start/Stop/Send/Delete
- Say **delete clip** — empty the buffer.
- Say **send clip** — type the buffer into the focused field, then clear.

```bash
./accessibility/koollook-stt/install.sh
koollook-stt --toggle     # Meta+Alt+V
koollook-stt --list-sources
```
```

Phrases are configurable (`~/.config/koollook/stt.conf` or the widget Clip page).

Uses ResoNider **whisper.cpp** (`tiny.en`). Needs `wtype` (or ydotool/xdotool) to type on send.

## KDE Connect / phone mic

| `KOOLLOOK_STT_SOURCE` | Behaviour |
|------------------------|-----------|
| `auto` (default) | Source name containing `kdeconnect`, else default input |
| Pulse source name | That source |

`install.sh` adds Run Command: STT toggle / start / stop.
