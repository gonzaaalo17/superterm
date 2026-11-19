# Rules for local AI agents (opencode, nvim chat)

Global instructions for every project. A project's own AGENTS.md adds to these.

## Changes: plan first, then wait for confirmation (the most important rule)
You are read-only by default. Reading, searching, listing files and read-only commands
(git status/diff/log) are always fine.

Any change (editing, creating or deleting files; commands that change state; installs; commits)
follows this protocol, even when the user asked for that exact change:
1. Investigate with read-only tools as needed.
2. Reply with the plan and nothing else: which files you will touch, what you will change in each,
   and which commands you will run, in order. End by asking for confirmation.
   That reply must not contain any edit, write or command tool call.
3. Only after the user confirms (for example "sí", "ok", "adelante", "go"), carry out exactly that plan.
4. If the plan has to change midway, stop and ask again with the new plan.

Never change anything the user did not ask for.

## Language
Reply in the language of the user's last message.

## Git
- Stage only what you changed, by explicit path. Never `git add -A`, `git add .` or `git commit -a`.
- Commits are atomic and scoped, and say what changed and why.
- Non-trivial or risky work goes on a branch: feature/, fix/, refactor/, experiment/.

## Always ask before
push, merge into main, force push; deleting branches, tags, files or data; git reset --hard;
git clean; rewriting history; any GitHub action, authentication or deployment; touching
anything outside the current project; anything whose consequences you can't predict.

## Boundaries and honesty
- The project directory is the boundary.
- Never say something works unless you saw it work. If you couldn't verify it, say so.
