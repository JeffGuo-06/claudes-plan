#!/usr/bin/env bash
# Sound player + lightweight priority control + volume.
#
#   play.sh <file.wav>          play async, recording the player's PID
#   play.sh --stop <file.wav>   stop that sound if it's still playing
#   play.sh --active <file.wav> exit 0 if that sound is still playing, else 1
#
# Volume (0.0 mute .. 1.0 full) is resolved from, in order:
#   1. the CLAUDESPLAN_VOLUME env var
#   2. the volume.conf file at the plugin root
#   3. default 1.0
#
# PIDs are recorded per sound so a later hook can interrupt or defer to an
# in-flight sound.

mode="play"; sound="$1"
case "$1" in
  --stop)   mode="stop";   sound="$2" ;;
  --active) mode="active"; sound="$2" ;;
esac
[ -n "$sound" ] || exit 0

root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
pidx="${TMPDIR:-/tmp}/claudes-plan-pids"
pidfile="${pidx}/${sound}.pid"

# True if the recorded PID is alive AND still the audio player we launched
# (guards against killing an unrelated process that reused the PID).
sound_alive() {
  [ -f "$pidfile" ] || return 1
  read -r pid player < "$pidfile"
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null || return 1
  case "$(ps -p "$pid" -o comm= 2>/dev/null)" in *"$player"*) return 0 ;; esac
  return 1
}

case "$mode" in
  active)
    sound_alive && exit 0 || exit 1 ;;
  stop)
    if sound_alive; then read -r pid _ < "$pidfile"; kill "$pid" 2>/dev/null; fi
    rm -f "$pidfile"; exit 0 ;;
esac

file="${root}/audio/${sound}"
[ -f "$file" ] || exit 0

# Resolve master volume: env override -> config file -> default.
vol="${CLAUDESPLAN_VOLUME:-}"
if [ -z "$vol" ]; then
  vol=$(grep -vE '^[[:space:]]*#' "${root}/volume.conf" 2>/dev/null \
        | grep -oE '[0-9]+(\.[0-9]+)?' | head -1)
fi
[ -z "$vol" ] && vol="1.0"
# Mute when <= 0.
awk "BEGIN{exit !($vol<=0)}" && exit 0

player=""
if command -v afplay >/dev/null 2>&1; then
  player="afplay"
  afplay -v "$vol" "$file" >/dev/null 2>&1 &
elif command -v paplay >/dev/null 2>&1; then
  player="paplay"
  pav=$(awk "BEGIN{v=$vol*65536; if(v>65536)v=65536; printf \"%d\", v}")
  paplay --volume="$pav" "$file" >/dev/null 2>&1 &
elif command -v aplay >/dev/null 2>&1; then
  player="aplay"                       # no per-clip volume; uses system mixer
  aplay "$file" >/dev/null 2>&1 &
elif command -v ffplay >/dev/null 2>&1; then
  player="ffplay"
  fav=$(awk "BEGIN{v=$vol*100; if(v>100)v=100; printf \"%d\", v}")
  ffplay -volume "$fav" -nodisp -autoexit -loglevel quiet "$file" >/dev/null 2>&1 &
elif command -v powershell.exe >/dev/null 2>&1; then
  player="powershell.exe"              # no per-clip volume; uses system volume
  powershell.exe -NoProfile -c "(New-Object Media.SoundPlayer '$file').PlaySync();" >/dev/null 2>&1 &
else
  exit 0
fi

mkdir -p "$pidx" 2>/dev/null
printf '%s %s' "$!" "$player" > "$pidfile"
exit 0
