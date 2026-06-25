#!/usr/bin/env bash
# UserPromptSubmit handler. Fires once when you submit a prompt. Checks the
# prompt text for "ultrathink" and whether you're currently in plan mode.
input=$(cat)

root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
play() { "${root}/scripts/play.sh" "$1"; }

prompt=$(printf '%s'  "$input" | jq -r '.user_prompt // .prompt // empty')
mode=$(printf '%s'    "$input" | jq -r '.permission_mode // "default"')
session=$(printf '%s' "$input" | jq -r '.session_id // "default"')

printf '%s' "$prompt" | grep -iq 'ultrathink' && play ultrathink.wav

# Only fire plan_mode.wav on the transition INTO plan mode: previous prompt's
# mode was not "plan" and this one is. Staying in plan mode stays silent.
state="${TMPDIR:-/tmp}/claudes-plan-mode-${session}"
prev=$(cat "$state" 2>/dev/null || echo "default")
[ "$mode" = "plan" ] && [ "$prev" != "plan" ] && play plan_mode.wav
printf '%s' "$mode" > "$state"
exit 0
