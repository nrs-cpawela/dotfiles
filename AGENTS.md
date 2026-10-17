# Agent instructions (dotfiles)

Chezmoi-managed **work-machine** dotfiles for macOS (`github.com/nrs-cpawela/dotfiles`). Windows 11 is a future apply path. This repo is the source of truth for shell, git, Homebrew splits, editor extension lists, and docs. It is not an application codebase.

## Non-negotiables

- Edit chezmoi source under `home/`, then `make apply`. Do not edit live `~/.zshrc`, `~/.gitconfig`, or other applied files in place.
- `Brewfile` is dotfiles-required CLI only. Daily tools go in `Brewfile.cli`, GUI casks in `Brewfile.apps`.
- `Extfile` entries must resolve on **both** Microsoft Marketplace and OpenVSX, or `make ext` fails on one editor.
- Public repo. No employer hostnames, fleet IPs, or secrets in committed files. Work-derived skills live in the private work repo, never in `Skillfile`.
- Do not add Cursor **agent** shell integration globally in `home/dot_zshrc` (network latency on every shell). See `docs/shell.md`.

Always-on guardrails also live in `.cursor/rules/dotfiles.mdc` (same content, rule injection).

## First commands

```bash
make help      # all targets
make lint      # before commit (gitleaks, yaml, whitespace, …)
make apply     # after changing home/ templates
git status && git diff
```

Bootstrap and Brew splits: [docs/bootstrap.md](docs/bootstrap.md), [docs/brew.md](docs/brew.md). Full doc index: [docs/README.md](docs/README.md).

## Repo map (short)

| Path | Role |
|------|------|
| `home/` | Chezmoi source (`dot_foo` → `~/.foo`, `private_` → mode 600, `.tmpl` templates) |
| `Makefile` | Single entry point |
| `Brewfile*` / `Extfile*` | Homebrew and VS Code + Cursor extensions |
| `scripts/` | Makefile helpers (e.g. `ext.sh`, `skills.sh`) |
| `Skillfile` / `Skillfile.lock` / `vendor/` | Personal Cursor skills: upstream sources, pinned commits, pristine upstream copies |
| `docs/` | Human runbooks |

Git identity is **path-based** (`includeIf` in `home/dot_gitconfig.tmpl`), not per laptop. Do not collapse work and personal profiles.

Machine-local only (not in git): `~/.zshenv.local`, `~/.zshrc.local`, `Skillfile.local`.

## Continuing from a prior session

Models do not retain memory between chats. Use repo files first, then attach prior context.

1. Read this file and `.cursor/rules/dotfiles.mdc`.
2. Reconstruct state from git (`git status`, `git log -5`, `git diff` vs `main`). Treat the branch and commits as authoritative over chat summary.
3. Optional prior context: `@Chats` for a previous Cursor thread, or invoke `@handoff` (personal skill under `~/.cursor/skills/handoff` after `make apply`) for a compact handoff doc.
4. For structured resume in this repo, run **`/resume-dotfiles`** (project skill in `.cursor/skills/resume-dotfiles/`).
5. For rigorous multi-step work, start with **`/poteto-mode`** (pstack plugin). Session pickup playbook lives in pstack; before pausing long work, use pstack **pause safely** (`wip:` commit + `/tmp/<slug>-resume.md`).

Do not redo work already landed on the branch unless verification failed on the real artifact (`make apply`, `make lint`, or the behavior under change).

## Common tasks

| Goal | Action |
|------|--------|
| New dotfile | Edit `home/` or `chezmoi add ~/.foo`, then `make apply` |
| Core CLI for dotfiles | `Brewfile` + `make brew-bundle` |
| Daily CLI / GUI | `Brewfile.cli` / `Brewfile.apps` + `make cli` / `make apps` |
| Editor extensions | Edit `Extfile*` + `make ext`; drift check `make ext-diff` |
| Cursor plugins & skills | [docs/cursor-plugins.md](docs/cursor-plugins.md); personal skills in `home/dot_cursor/skills/` |
| Update skills from upstream | `make skills`, then `make skills-pull NAME=x`, review `git diff`, `make apply` |

## Before you commit

Only commit when the user asks. When they do:

```bash
make lint
make apply
```

Pre-commit runs secret scanning. Do not skip hooks unless the user explicitly requests it.
