# Chezmoi

Source root: `home/` (set by `.chezmoiroot` at the repo root).

## Source layout

<details>
<summary>home/ tree, dot_ prefix, private_, .tmpl</summary>

Chezmoi maps files under `home/` to your home directory:

| Source pattern | Destination | Meaning |
|----------------|-------------|---------|
| `dot_zshrc` | `~/.zshrc` | `dot_` → `.` at the front of the basename |
| `dot_config/fzf/fzf.zsh` | `~/.config/fzf/fzf.zsh` | `dot_config/` → `.config/` |
| `private_dot_ssh/private_config.tmpl` | `~/.ssh/config` | directory `private_` → `~/.ssh` mode 700; file `private_` → mode 600 |
| `*.tmpl` | rendered on apply | Go templates; `.tmpl` suffix stripped |

Edit files in `~/dotfiles/home/` (or use `chezmoi edit ~/.zshrc` to open the source path).

</details>

## Init config

<details>
<summary>sourceDir, no home/work prompt</summary>

`home/.chezmoi.toml.tmpl` writes `~/.config/chezmoi/chezmoi.toml` on first init. It does **not** ask home vs work. Hardware is work-only (this Mac now; Windows later). Git identity is a separate path-based system — see [Git identity](#git-identity).

```toml
sourceDir = "~/dotfiles"
[git]
    autoCommit = false
    autoPush = false
```

Because `sourceDir` is baked in, plain `chezmoi apply` works after init — no need to pass `--source` every time.

Older configs may still have unused `[data] machine`. Harmless. `make reinit` rewrites `chezmoi.toml` from the template.

Windows is a **different apply path** (second chezmoi source or a second repo), not a chezmoi data field.

</details>

## Git identity

<details>
<summary>Path-based includeIf — not chezmoi prompts</summary>

`home/dot_gitconfig.tmpl` sets a **default personal identity** at the top, then uses `includeIf "gitdir:…"` rules to override by working directory:

| Path prefix | Included file | `user.name` / `user.email` |
|-------------|---------------|----------------------------|
| `~/development/` | `~/.gitconfig.work` (`dot_gitconfig.work`), which includes `~/.gitconfig.work.local` | `<work-name>` / `<work-email>` |
| `~/home/` | `~/.gitconfig.personal` (`dot_gitconfig.personal`) | nrs-cpawela / 67277432+nrs-cpawela@users.noreply.github.com |
| `~/dotfiles/` | `~/.gitconfig.personal` | nrs-cpawela / 67277432+nrs-cpawela@users.noreply.github.com |
| everywhere else | default in `dot_gitconfig.tmpl` | nrs-cpawela / 67277432+nrs-cpawela@users.noreply.github.com |

Trailing slashes on `gitdir:` paths matter — they mean “this directory and everything under it.”

Edit the hardcoded values in `dot_gitconfig.tmpl` and `dot_gitconfig.personal` directly; no chezmoi template variables for name or email. The work name and email live only in `~/.gitconfig.work.local`, a machine-local file outside this public repo. Create it on a new machine with a `[user]` block. Use placeholders like `<work-name>` / `<work-email>` in docs.

`dot_gitconfig.tmpl` also sets `core.excludesfile` to `~/.gitignore_global` (source: `home/dot_gitignore_global`).

</details>

## Common commands

<details>
<summary>apply, diff, edit, cd, source-path</summary>

Or from the repo root: `make apply`, `make diff`, `make edit FILE=~/.zshrc`, etc. (`make help`).

```bash
# First time (bootstrap does this)
chezmoi init --source=~/dotfiles/home

# After editing repo — sourceDir is already configured
chezmoi apply

# See what would change
chezmoi diff

# Edit source file in repo (opens $EDITOR on the chezmoi source path)
chezmoi edit ~/.zshrc

# Jump to chezmoi source root
chezmoi cd

# Print path to a managed file's source
chezmoi source-path ~/.zshrc

# Add a new file from home into the repo
chezmoi add ~/.some-config
```

</details>

## Templates

<details>
<summary>dot_gitconfig.tmpl, private_dot_ssh/private_config.tmpl</summary>

| Source | Notes |
|--------|-------|
| `home/dot_gitconfig.tmpl` | Default git config + `includeIf` rules; includes `.personal` / `.work` fragments |
| `home/dot_gitignore_global` | Global ignore patterns via `core.excludesfile` |
| `home/private_dot_ssh/private_config.tmpl` | Static sanitized `Host *` defaults (mode 600). `Include config.local` reads work hosts from machine-local `~/.ssh/config.local` |

</details>
