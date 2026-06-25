#!/usr/bin/env bash
# Low-level player: play a sound from the plugin's audio/ folder, async, never
# blocking Claude. Cross-platform: tries the first available audio backend.
# Usage: play.sh <filename.wav>
sound="$1"
[ -n "$sound" ] || exit 0

root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
file="${root}/audio/${sound}"
[ -f "$file" ] || exit 0

if command -v afplay >/dev/null 2>&1; then                 # macOS
  afplay "$file" >/dev/null 2>&1 &
elif command -v paplay >/dev/null 2>&1; then               # Linux / PulseAudio
  paplay "$file" >/dev/null 2>&1 &
elif command -v aplay >/dev/null 2>&1; then                # Linux / ALSA
  aplay "$file" >/dev/null 2>&1 &
elif command -v ffplay >/dev/null 2>&1; then               # ffmpeg
  ffplay -nodisp -autoexit -loglevel quiet "$file" >/dev/null 2>&1 &
elif command -v powershell.exe >/dev/null 2>&1; then       # Windows (WSL / Git Bash)
  powershell.exe -NoProfile -c "(New-Object Media.SoundPlayer '$file').PlaySync();" >/dev/null 2>&1 &
fi
exit 0
