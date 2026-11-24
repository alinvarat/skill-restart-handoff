#!/bin/bash
# Open a new Claude Code session (Remote Control on, like the user's own sessions) in a new gnome-terminal tab
# and give it PROMPT_FILE as the first message.
# usage: new-session.sh PROMPT_FILE [WORKDIR]
# WORKDIR defaults to the directory the current Claude session was launched in (already known to the user),
# not the shell's cwd, which may have wandered into an untrusted folder.
# prints "started <session-name> pid=<pid>" on success, exits 1 with a reason otherwise.
f=$(readlink -f -- "${1:?usage: new-session.sh PROMPT_FILE [WORKDIR]}") || exit 2
[ -s "$f" ] || { echo "prompt file missing or empty: $f"; exit 2; }
dir=$(readlink -f -- "${2:-$(readlink "/proc/${CLAUDE_PID:-0}/cwd" 2>/dev/null || echo "$PWD")}")
command -v gnome-terminal >/dev/null || { echo "no gnome-terminal"; exit 1; }
command -v claude >/dev/null || { echo "no claude command"; exit 1; }
[ -n "$WAYLAND_DISPLAY$DISPLAY" ] || { echo "no graphical session"; exit 1; }
name="handoff-$(date +%Y%m%d-%H%M%S)"
# The tab must not inherit the old session's identity, or claude may treat itself as a child of it.
gnome-terminal --tab --working-directory="$dir" -- bash -c '
  for v in $(compgen -e | grep -E "^(CLAUDECODE|CLAUDE_CODE_|CLAUDE_PID)"); do unset "$v"; done
  export CLAUDE_CODE_FORCE_SESSION_PERSISTENCE=1
  exec claude --remote-control "$1" --name "$1" -- "$(cat -- "$2")"' _ "$name" "$f"
for _ in $(seq 1 100); do   # up to 10 s for the process to appear
  pid=$(pgrep -f -- "^claude --remote-control $name --name $name " | head -1)
  [ -n "$pid" ] && { echo "started $name pid=$pid"; exit 0; }
  sleep 0.1
done
echo "tab opened but no claude process named $name appeared"; exit 1
