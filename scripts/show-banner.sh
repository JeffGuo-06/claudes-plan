#!/usr/bin/env bash
# One-time colored album-cover banner, shown on the first session after install.
#
# A SessionStart hook's stdout is captured as model context rather than shown
# to the user, so we write the banner straight to the controlling terminal
# (/dev/tty) where the ANSI colors actually render. A flag file makes it
# fire exactly once; bump the flag name (e.g. -v2) to re-greet on an upgrade.

root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
flag="${HOME}/.claude/.claudes-plan-welcomed"

# Already greeted? Stay silent.
[ -f "$flag" ] && exit 0

banner="${root}/assets/banner.ansi"
[ -f "$banner" ] || exit 0

# Caption lines under the image, centered to the 50-col banner width.
teal=$'\033[38;2;78;201;176m'; dim=$'\033[2;38;2;154;154;154m'; rst=$'\033[0m'
line1="welcome to the claude's plan plugin"            # 35 chars -> 7 spaces in
line2="enjoy"                                          #  5 chars -> 22 spaces in

# Only print if we have a real terminal to draw on.
if [ -w /dev/tty ]; then
  {
    printf '\n'
    cat "$banner"
    printf '\n%*s%s%s%s\n'  7 '' "$teal" "$line1" "$rst"
    printf '%*s%s%s%s\n\n' 22 '' "$dim"  "$line2" "$rst"
  } > /dev/tty 2>/dev/null
  mkdir -p "$(dirname "$flag")" 2>/dev/null
  touch "$flag"
fi

exit 0
