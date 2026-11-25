---
name: restart-handoff
description: Hand off to a new chat on เริ่มใหม่ or another request to move to a new chat (ย้ายไปแชตใหม่); performs the เก็บหมด save itself, launches Claude and verifies receipt. Not for restarting devices/apps/tasks.
---

# Restart handoff
Use only for a chat handoff. A prompt/summary-only request does not launch a session or trigger a save by itself.

1. Read any saved memory or notes available and inspect relevant project state. For a move-chat request, save the context once here before launching (if a memory mechanism exists). Acknowledge already saved records and update only new information. Save verified results, user decisions, exact artifact paths, unfinished work, blockers and next steps; never invent prior history or include secrets.
2. Prepare a short self-contained continuation prompt: goal, constraints, notes/task paths, verified state, missing evidence and immediate next step. Old approvals do not authorize new external side effects.
3. If the user gave a command with เริ่มใหม่, use that exact command as the first message, followed by pointers to saved notes. Otherwise use the continuation prompt. For a prompt-only request, return the prompt and stop.
4. Write the first message to `~/.local/state/restart-handoff/prompt.txt`, mode 600. Use a file so quotes/backticks/$ remain literal. Keep credentials out.
5. Launch from the original session directory:
```bash
bash "$HOME/.claude/skills/restart-handoff/scripts/new-session.sh" ~/.local/state/restart-handoff/prompt.txt
```
The script opens `claude --remote-control` in a new terminal tab. `started handoff-… pid=…` means a process appeared, not that the handoff succeeded.
6. Read [startup prompts](references/startup-prompts.md) and use `debian-desktop-control` to inspect/handle only authorized startup screens. Do not type task commands into the new session. Never enter passwords/OTP/CAPTCHA or accept payment/destructive/unreadable prompts.
7. Verify by screenshot that the first message arrived and work began. Then stop the original task here to avoid duplicate work; leave this session open. Report the new session name and any unverified part in Thai, at most three lines.

If graphical launch, startup handling or receipt verification fails: state the failure first and return the complete continuation prompt in a fenced text block. Do not claim success from a PID alone. Do not restart the machine or perform the handed-off work twice. Create an extra handoff file only if explicitly requested or the project already uses one.
