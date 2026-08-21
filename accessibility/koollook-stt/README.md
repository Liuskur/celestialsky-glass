# Koollook STT (accessibility)

Local **English** speech-to-text that types into the focused field. No cloud.

Uses ResoNider’s **whisper.cpp** (`tiny.en`) and the same English model as `config.en-async.json`.

```bash
./accessibility/koollook-stt/install.sh
koollook-stt --toggle     # Meta+Alt+V
koollook-stt --list-sources
```

Needs `wtype` (preferred), or `ydotool` / `xdotool`, to inject keys. Without those it copies to the clipboard.

## Audio sources (KDE Connect phone mic)

Capture is **PipeWire/Pulse**, not a hardcoded ALSA device.

| `KOOLLOOK_STT_SOURCE` | Behaviour |
|------------------------|-----------|
| `auto` (default) | If a source name contains `kdeconnect`, use it; else the default input |
| a Pulse source name | That source only |

When KDE Connect (or a later audio plugin) exposes the phone as a Pulse/PipeWire source, dictation uses the phone microphone with no code change.

Until that source exists: use the computer mic, and start/stop listening from the phone via **KDE Connect → Run Command**:

- Koollook STT toggle
- Koollook STT start
- Koollook STT stop

`install.sh` adds those commands to each paired device.

English only for now (`-l en`, `ggml-tiny.en-q5_1.bin`).
