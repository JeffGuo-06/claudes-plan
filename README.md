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

## Commands

- `/claudes-plan:help` — overview of every sound and command
- `/claudes-plan:volume [0.0-1.0]` — set the volume (e.g. `0.3`)
- `/claudes-plan:volume mute` / `unmute` — toggle sound off/on
- `/claudes-plan:volume` — show the current volume

## What plays when

| Sound | Fires when |
|---|---|
| `commit.wav` | Claude runs `git commit` |
| `skimming_through_prs_LGTM.wav` | Claude runs a `gh pr` command |
| `md.wav` | Claude **creates** a `.md` file |
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

## Volume

Master volume runs `0.0` (mute) to `1.0` (full). Easiest is the slash command:

```text
/claudes-plan:volume 0.3
/claudes-plan:volume mute
```

It saves to `~/.config/claudes-plan/volume.conf`, which every sound reads and which
survives plugin updates. To override for a single session, set the
`CLAUDESPLAN_VOLUME` env var (in Claude Code's settings `env`, or your shell):

```bash
export CLAUDESPLAN_VOLUME=0.3   # quieter
export CLAUDESPLAN_VOLUME=0     # mute
```

Resolution order: `CLAUDESPLAN_VOLUME` env var → `~/.config/claudes-plan/volume.conf`
→ bundled default → `1.0`.

Per-clip volume works on `afplay` (macOS), `paplay`, and `ffplay`. `aplay` and the
Windows PowerShell fallback have no per-clip control, so they play at system volume
(but `0` still mutes by skipping playback entirely).

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
