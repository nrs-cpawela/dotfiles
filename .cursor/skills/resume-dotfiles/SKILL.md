---
name: resume-dotfiles
description: Resume dotfiles work in a fresh Cursor session. Reconstruct git and chezmoi state, read AGENTS.md guardrails, and continue without redoing landed changes.
disable-model-invocation: true
---

Pick up work on `github.com/nrs-cpawela/dotfiles` after a new chat or agent swap.

## Read first

1. [AGENTS.md](../../../AGENTS.md) at the repo root (identity, non-negotiables, doc index).
2. `.cursor/rules/dotfiles.mdc` (always-applied guardrails).

Do not edit live `~/.foo` files. All dotfile changes go through `home/` and `make apply`.

## Reconstruct state

Run in the repo root:

```bash
git status
git branch -vv
git log -10 --oneline
git diff
git diff main...HEAD 2>/dev/null || git diff origin/main...HEAD
```

Treat git as authoritative over chat summaries. Note open PRs only if the user named one (`gh pr view` when relevant).

## Prior trail (optional)

- User attached `@Chats` or a handoff path: read it after git state, for intent and pending items only.
- Local transcript for **this workspace only**: `agent-transcripts/` under the Cursor project folder named in the system prompt. Do not glob other projects under `~/.cursor/projects/`.
- Cloud agent URL: fetch if the user supplied it.

## Diff done vs pending

- Landed on the branch: do not re-implement; verify if the user asked for proof (`make apply`, `make lint`, or targeted checks).
- Uncommitted or planned in chat only: that is the resume point.

## Route next work

- Docs-only or wiring: edit `docs/` or `home/`, then `make apply` when templates change.
- Brew or extensions: the matching `Brewfile*` or `Extfile*` + documented `make` target.
- Non-trivial or cross-cutting: suggest `/poteto-mode` with the remaining task.

## Reply format

State where the prior work stopped, what git shows, what you will do next, and what you deliberately did **not** redo.
