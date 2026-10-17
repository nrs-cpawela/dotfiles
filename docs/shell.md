# Shell

Config paths in the chezmoi `home/` tree and live destinations after `chezmoi apply`.

## zsh

<details>
<summary>~/.zshrc, ~/.zprofile, ~/.zshenv</summary>

| Repo source | Destination |
|-------------|-------------|
| `home/dot_zshrc` | `~/.zshrc` |
| `home/dot_zprofile` | `~/.zprofile` |
| `home/dot_zshenv` | `~/.zshenv` |

**Prompt:** Starship (`eval "$(starship init zsh)"`).

**Hooks:** atuin, zoxide, direnv — each gated on `command -v`. fastfetch is **not** auto-run.

**Homebrew prefix:** login shells get `HOMEBREW_PREFIX` from `brew shellenv` in `~/.zprofile` (ARM `/opt/homebrew` or Intel `/usr/local`). `dot_zshrc` and `fzf.zsh` use that variable. They do not call `brew --prefix` on every interactive start.

**No-brew Macs (mise):** `~/.zprofile` adds `~/.local/share/mise/shims` to `PATH`; `dot_zshrc` runs `mise activate zsh`. With no `HOMEBREW_PREFIX`, `fzf.zsh` loads `fzf --zsh` and zsh-syntax-highlighting comes from `~/.local/share/zsh-syntax-highlighting`. See [bootstrap.md](bootstrap.md#intel-mac-no-homebrew).

**Completions:** `compinit -C` reuses `~/.zcompdump` when it is younger than 24 hours. `make clean` deletes the dump so the next shell rebuilds it. `zsh-syntax-highlighting` is sourced last, only if the file exists.

**Cursor Agent:** do **not** put `eval "$(~/.local/bin/agent shell-integration zsh)"` in `.zshrc` or `.zprofile`. That script runs `agent create-chat` (network, ~1.4s) on every new TTY and can `exec agent record`. Keep `~/.local/bin` on PATH. Use Cursor's own terminal integration inside the IDE.

**Machine-local (not in git):** `~/.zshenv.local` for PATH extras (Go/`ark`). `~/.zshrc.local` for interactive extras (Perforce `p4colors`). Shared `dot_zshrc` / `dot_zshenv` source those files if present.

**SSH:** no wrapper needed. Ghostty is configured with `term = xterm-256color` so the universal terminfo entry is used everywhere (local + remote). See `home/dot_config/ghostty/config` for the rationale (heterogeneous remote SSH targets where `xterm-ghostty` terminfo isn't available).

</details>

## Starship

<details>
<summary>~/.config/starship.toml</summary>

| Repo source | Destination |
|-------------|-------------|
| `home/dot_config/starship.toml` | `~/.config/starship.toml` |

Minimal config with character prompt symbols. Extend as needed.

</details>

## fzf

<details>
<summary>~/.config/fzf/fzf.zsh + FZF_* opts in zshrc</summary>

| Repo source | Destination |
|-------------|-------------|
| `home/dot_config/fzf/fzf.zsh` | `~/.config/fzf/fzf.zsh` |

`dot_zshrc` sources **only** `~/.config/fzf/fzf.zsh` (not `~/.fzf.zsh`). That file adds fzf to `PATH`, loads completion, and installs key bindings from the Homebrew fzf package. An old `~/.fzf.zsh` from `fzf/install` is unused and can be deleted.

**Appearance** (`FZF_DEFAULT_OPTS` in `dot_zshrc`): Tokyo Night palette, `--border=rounded`.

**Previews** (gated on installed tools):

| Binding | Preview | Requires |
|---------|---------|----------|
| Ctrl+T | `bat` on selected file | `bat` |
| Alt+C | `eza --tree` on selected directory | `eza` |
| Ctrl+/ | toggle preview pane | either binding above |

</details>

## AWS helpers

<details>
<summary>~/.config/zsh/aws.zsh</summary>

| Repo source | Destination |
|-------------|-------------|
| `home/dot_config/zsh/aws.zsh` | `~/.config/zsh/aws.zsh` |

`dot_zshrc` sources this file after `compinit` when the `aws` CLI is installed. It defines `awsp`, `awsr`, `awsu`, and `awsw`. Usage is in [toolkit.md](toolkit.md#awscli).

`awsp` checks the profile and region before it changes any environment variable. For an SSO profile, it first runs `aws sts get-caller-identity`. If that fails, it runs `aws sso login`. A failed login leaves the shell unchanged.

The profile picker and Tab completion read profile names from `~/.aws/config` and `~/.aws/credentials` with awk, so they do not start the AWS CLI. `AWS_CONFIG_FILE` and `AWS_SHARED_CREDENTIALS_FILE` override those paths.

</details>

## fastfetch

<details>
<summary>~/.config/fastfetch/config.jsonc</summary>

| Repo source | Destination |
|-------------|-------------|
| `home/dot_config/fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` |

Run on demand: `fastfetch`. Not invoked from `.zshrc`.

**Remote systems:** run it over SSH against the *remote's* OS info with:

```bash
ssh user@host fastfetch --logo none --pipe
```

This requires `fastfetch` to be installed on the remote host. `--pipe` strips ANSI colors for cleaner output in non-TTY contexts; drop it for colorized output. To see *your local* machine's info from inside an SSH session, just type `fastfetch` after connecting (assuming your dotfiles are synced there too).

</details>

## tmux

<details>
<summary>~/.tmux.conf + TPM</summary>

| Repo source | Destination |
|-------------|-------------|
| `home/dot_tmux.conf` | `~/.tmux.conf` |

Plugins: tpm, sensible, resurrect, continuum.

After apply: `prefix + I` in tmux to install plugins (bootstrap clones TPM if missing).

</details>

## Ghostty

<details>
<summary>~/.config/ghostty/config</summary>

| Repo source | Destination |
|-------------|-------------|
| `home/dot_config/ghostty/config` | `~/.config/ghostty/config` |

</details>

## Git ignores

Global patterns live in `home/dot_gitignore_global` → `~/.gitignore_global`, wired through `core.excludesfile` in `dot_gitconfig.tmpl`. See [chezmoi.md](chezmoi.md#git-identity).

## Tool cheat-sheet

<details>
<summary>Common commands</summary>

| Tool | Reminder |
|------|----------|
| atuin | `atuin register` after install |
| zoxide | `z <dir>` to jump |
| direnv | `.envrc` in project dirs |
| eza | `alias ll` still uses `ls` — switch to `eza` later |
| bat | `bat file` instead of `cat` |

</details>
