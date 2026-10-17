# dotfiles

Chezmoi-managed **macOS** dotfiles for work machines: Ghostty, zsh, Starship, tmux, git, Homebrew, editor extensions.

Windows 11 is a later apply path (separate tree or repo). Git identity is path-based and independent of OS — see [docs/chezmoi.md](docs/chezmoi.md).

## Quick start

```bash
git clone https://github.com/nrs-cpawela/dotfiles ~/dotfiles
cd ~/dotfiles
make bootstrap          # Xcode CLT, Homebrew, core Brewfile, chezmoi apply, TPM, hooks
make help               # all targets
```

Intel Mac: `make bootstrap` uses mise instead of Homebrew (Tier 3 on Intel) — no sudo needed. See [docs/bootstrap.md](docs/bootstrap.md#intel-mac-no-homebrew).

On a machine that already has brew and git: `make brew-bundle`, `make apply`, plus `make cli` / `make apps` / `make ext` as needed. Details: [docs/bootstrap.md](docs/bootstrap.md).

## Layout

| Path | Role |
|------|------|
| `home/` | Chezmoi source (`.chezmoiroot` is `home`). `dot_zshrc` → `~/.zshrc`. Edit here, never live `~/.foo`. |
| `Makefile` | Single entry point (`make help`) |
| `Brewfile` | Tools the dotfiles themselves need — `make brew-bundle` |
| `Brewfile.cli` | Daily CLI — `make cli` |
| `Brewfile.apps` | GUI casks — `make apps` |
| `Brewfile.archive` | Gitignored historical dump — do not commit |
| `Extfile*` | VS Code + Cursor extensions — `make ext` |
| `scripts/` | Makefile helpers (`ext.sh`) |
| `docs/` | [Index](docs/README.md) |
| `AGENTS.md` | Cursor agent baseline (new session / cloud) |

Machine-local shell extras (not in git): `~/.zshenv.local`, `~/.zshrc.local`.

## Git identity

By directory, not by laptop:

| Path | Identity |
|------|----------|
| `~/development/` | work (`~/.gitconfig.work`) |
| `~/home/` and `~/dotfiles/` | personal (`~/.gitconfig.personal`) |
| everywhere else | personal default in `~/.gitconfig` |

## Docs

Full index: [docs/README.md](docs/README.md).

After bootstrap: `make cli`, `make apps`, and `make ext` when you want those extras, then `gh auth login`, `atuin register`, and in tmux `prefix + I` for TPM plugins.
