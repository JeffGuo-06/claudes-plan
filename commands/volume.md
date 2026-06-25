---
description: Set or check the claudes-plan sound-effect volume (0.0–1.0, or mute/unmute)
argument-hint: "[0.0-1.0 | mute | unmute]"
allowed-tools: Bash
disable-model-invocation: true
---

Run the following command exactly as written, then show the user only its final
output line (the 🔊/🔇/⚠️ message). Do not add commentary.

```bash
dir="${XDG_CONFIG_HOME:-$HOME/.config}/claudes-plan"; mkdir -p "$dir"; f="$dir/volume.conf"
arg="$(printf '%s' "$ARGUMENTS" | tr -d '[:space:]')"
cur() { if [ -f "$f" ]; then cat "$f"; else echo 1.0; fi; }
case "$arg" in
  "")            echo "🔊 claudes-plan volume is $(cur) (0.0 mute – 1.0 full)" ;;
  mute|off)      echo 0   > "$f"; echo "🔇 claudes-plan muted." ;;
  unmute|on|full) echo 1.0 > "$f"; echo "🔊 claudes-plan volume set to 1.0 (full)." ;;
  *) if printf '%s' "$arg" | grep -qE '^(0(\.[0-9]+)?|1(\.0+)?)$'; then
       echo "$arg" > "$f"; echo "🔊 claudes-plan volume set to $arg."
     else
       echo "⚠️  Volume must be 0.0–1.0, or 'mute'/'unmute' — got '$arg'."
     fi ;;
esac
```

The value is saved to `~/.config/claudes-plan/volume.conf`, which all sound effects
read and which persists across plugin updates. It can be overridden for a single
session with the `CLAUDESPLAN_VOLUME` environment variable.
