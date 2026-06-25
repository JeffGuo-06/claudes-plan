---
description: Show what the claudes-plan sound-effects plugin does and how to control it
disable-model-invocation: true
---

Display the following to the user verbatim as Markdown. Do not summarize, reorder,
or add commentary.

---

## 🔊 claudes-plan

*Sound effects for your Claude Code dev experience.*

The sounds are for you to discover as you work.

**Commands**

- `/claudes-plan:volume [0.0-1.0]` — set the volume (e.g. `0.3`)
- `/claudes-plan:volume mute` / `unmute` — toggle sound
- `/claudes-plan:volume` — show the current volume
- `/claudes-plan:help` — show this screen

**Configuration**

- Volume is saved to `~/.config/claudes-plan/volume.conf` and survives updates.
- Override for one session with the `CLAUDESPLAN_VOLUME` env var (`0.0`–`1.0`).
- Needs an audio backend on `PATH`: `afplay` (macOS), `paplay`/`aplay`/`ffplay`
  (Linux), or PowerShell (Windows via WSL/Git Bash).

*Repo: https://github.com/JeffGuo-06/claudes-plan*
