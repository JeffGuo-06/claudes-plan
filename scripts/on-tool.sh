#!/usr/bin/env bash
# PreToolUse dispatcher. Reads the hook JSON on stdin, inspects the tool and its
# input, and plays the matching sound effect. Bound to every tool (matcher ".*").
input=$(cat)

root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
play() { "${root}/scripts/play.sh" "$1"; }

tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
cmd=$(printf '%s'  "$input" | jq -r '.tool_input.command // empty')
fp=$(printf '%s'   "$input" | jq -r '.tool_input.file_path // empty')
text=$(printf '%s' "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')

# Pattern that looks like a leaked / hardcoded API key.
secret_re='API_KEY|ANTHROPIC_API_KEY|sk-[A-Za-z0-9]{6}|AKIA[0-9A-Z]{8}'

case "$tool" in
  Bash)
    # Match anywhere in the command so chained / multi-line scripts
    # (e.g. "cd x && git add . && git commit ...") still trigger.
    case "$cmd" in
      *"git commit"*) play commit.wav ;;
    esac
    case "$cmd" in
      *"gh pr "*) play skimming_through_prs_LGTM.wav ;;
    esac
    if printf '%s' "$cmd" | grep -Eq "$secret_re|\.env"; then play api_keys.wav; fi
    ;;

  Write)
    # Create-only: PreToolUse runs before the write, so a not-yet-existing
    # path means this Write is creating the .md, not overwriting one.
    case "$fp" in *.md) [ -e "$fp" ] || play md.wav ;; esac
    if printf '%s' "$fp" | grep -Eq '\.env'; then play api_keys.wav
    elif printf '%s' "$text" | grep -Eq "$secret_re"; then play api_keys.wav
    fi
    ;;

  Edit|MultiEdit|Read)
    if printf '%s' "$fp" | grep -Eq '\.env'; then play api_keys.wav
    elif printf '%s' "$text" | grep -Eq "$secret_re"; then play api_keys.wav
    fi
    ;;

  ExitPlanMode)
    play Here_is_claudes_plan.wav
    ;;

  mcp__*)
    play mcp.wav
    ;;
esac
exit 0
