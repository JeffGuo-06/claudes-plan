# claudes-plan 🔊

A joke Claude Code plugin that plays sound effects throughout your dev experience.
Claude commits? Airhorn. Claude reads your `.env`? Uh oh. You drop into plan mode?
Ding. It hooks into Claude Code events and plays a `.wav` for each.

## Install

In Claude Code:

```text
/plugin marketplace add JeffGuo-06/claudes-plan
/plugin install claudes-plan@claudes-plan
```

Then **restart Claude Code** so the hooks register. Check it's on with `/plugin`.

## What plays when

| Sound | Fires when |
|---|---|
| `commit.wav` | Claude runs `git commit` |
| `bad_change.wav` | Claude runs `git status` |
| `skimming_through_prs_LGTM.wav` | Claude runs a `gh pr` command |
| `md.wav` | Claude **writes** a `.md` file |
| `api_keys.wav` | Claude touches a `.env` file or a key pattern (`sk-…`, `API_KEY`, `AKIA…`) |
| `mcp.wav` | An MCP server tool is called |
| `context_window.wav` | The context window compacts (auto or `/compact`) |
| `orchestration_subagents.wav` | A subagent is launched |
| `ultrathink.wav` | Your submitted prompt contains "ultrathink" |
| `plan_mode.wav` | You enter plan mode (fires on the transition only) |
| `Here_is_claudes_plan.wav` | Claude presents a finished plan |

## Requirements & platforms

You need one of these audio players on your `PATH` (the plugin auto-detects):

- **macOS** — `afplay` (built in) ✅
- **Linux** — `paplay` (PulseAudio), `aplay` (ALSA), or `ffplay` (ffmpeg)
- **Windows** — works under **WSL** or **Git Bash** via PowerShell. Native
  `cmd.exe` can't run the bash hook scripts.

If no player is found, the hooks no-op silently — nothing breaks, you just get no sound.

## Caveats

- **`Here_is_claudes_plan.wav`** relies on the `ExitPlanMode` tool firing a
  `PreToolUse` hook. This works in practice but isn't formally documented, so it
  may go quiet on some versions.
- **`plan_mode.wav`** fires only on the *transition into* plan mode (tracked per
  session), so it won't re-trigger on every prompt while you stay in plan mode.

## How it works

Pure Claude Code hooks (no daemon). `hooks/hooks.json` wires events to small bash
scripts in `scripts/` that read the hook JSON on stdin and call `play.sh`, which
plays the matching file from `audio/` asynchronously so Claude is never blocked.
