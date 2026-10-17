# Bootstrap

`make bootstrap` is idempotent: each step detects what's already installed and logs `✓ already …` instead of redoing work.

After bootstrap, use `make <target>` from the repo root for daily ops (`make help` lists all targets).

## Fresh Mac

<details>
<summary>Typical order on a new machine</summary>

1. Install Xcode CLT: `xcode-select --install`
2. Clone repo to `~/dotfiles`
3. `cd ~/dotfiles && make bootstrap` — Homebrew, core Brewfile, chezmoi init/apply, TPM, pre-commit hooks
4. `make lint`

Daily extras are **not** in bootstrap — install when you want them: `make cli`, `make apps`, then `make ext` (see [editors.md](editors.md): apps before ext).

</details>

## Existing machine

<details>
<summary>Already have brew, git, fzf, etc.</summary>

Many core Brewfile tools may already be installed. Individual targets skip when done:

| Target | Skip when |
|--------|-----------|
| `make xcode-clt` | `xcode-select -p` succeeds |
| `make brew` | `brew` in PATH |
| `make brew-bundle` | per-formula (Homebrew skips installed) |
| `make chezmoi-init` | `~/.config/chezmoi/chezmoi.toml` exists |
| `make tpm-install` | `~/.tmux/plugins/tpm` exists |

Run only what you need:

```bash
make brew-bundle      # re-sync Brewfile packages
make apply            # apply dotfile changes without full bootstrap
make cli              # optional: Brewfile.cli daily CLI toolkit
make apps             # optional: Brewfile.apps GUI casks
make ext              # optional: editor extensions from Extfile (after apps if you use those editors)
```

</details>

## Bootstrap targets

<details>
<summary>What `make bootstrap` runs (in order)</summary>

| Target | What it does |
|--------|----------------|
| `xcode-clt` | Verify Xcode CLT; prompt install if missing |
| `brew` | Install Homebrew if missing |
| `brew-bundle` | `brew bundle --file=~/dotfiles/Brewfile` |
| `chezmoi-init` | `chezmoi init --source=~/dotfiles/home` |
| `apply` | `chezmoi diff` + `chezmoi apply` (includes `~/.config/fzf/fzf.zsh`) |
| `tpm-install` | Clone TPM to `~/.tmux/plugins/tpm` |
| `hooks-install` | `pre-commit install` |

On Intel Macs `brew` + `brew-bundle` are replaced by `mise-bundle` — see below.

</details>

## Intel Mac (no Homebrew)

<details>
<summary>mise + scripts/cask.sh instead of brew — picked automatically on Intel</summary>

Homebrew is [Tier 3](https://docs.brew.sh/Support-Tiers) on Intel macOS: no bottles, everything builds from source, no support. The Makefile reads the hardware (`sysctl hw.optional.arm64`) and sets `PKG_MGR=mise` on Intel, `brew` on Apple Silicon. Override with `make bootstrap PKG_MGR=brew|mise`.

Nothing on this path needs sudo; tools live under `~/.local`.

| Brew path | No-brew path | What it does |
|-----------|--------------|--------------|
| `brew` | `mise` | Install [mise](https://mise.jdx.dev) to `~/.local/bin/mise` |
| `brew-bundle` (formulae) | `mise-bundle` → `mise install` | Prebuilt x86_64 binaries listed in `home/dot_config/mise/config.toml` |
| `brew-bundle` (casks) | `mise-bundle` → `scripts/cask.sh Brewfile` | Ghostty → `/Applications`, Nerd Font → `~/Library/Fonts` |
| `zsh-syntax-highlighting` formula | `zsh-plugins` | Clone to `~/.local/share/zsh-syntax-highlighting` |
| `make upgrade` (brew) | `make upgrade` (mise) | `mise upgrade`, pull zsh-syntax-highlighting, re-install the pre-commit hook |

- **Tool list:** `home/dot_config/mise/config.toml` mirrors the formulae in `Brewfile`. Add a tool to both. The repo copy drives `make mise-bundle`; `make apply` deploys it to `~/.config/mise/config.toml`.
- **Shell:** `~/.zprofile` puts mise shims on `PATH` for login and non-interactive shells. `~/.zshrc` runs `mise activate zsh`. fzf key bindings come from `fzf --zsh`.
- **git:** Apple's Xcode CLT git — mise has no prebuilt macOS git.
- **Casks:** `scripts/cask.sh` reads each `cask "…"` line, fetches its metadata from `formulae.brew.sh`, picks the variation for this macOS + CPU, checks sha256, and installs `app` / `font` artifacts. It is install-only: Ghostty updates itself. Casks that ship a `pkg` installer or a standalone binary (e.g. `claude-code`) are refused with a message.
- **Not ported yet:** `make cli` (`Brewfile.cli`) and `make apps` (`Brewfile.apps`) stop with a message. Most of `Brewfile.cli` exists in mise (`mise registry <tool>`). Add what you need with `mise use -g <tool>`, then copy the line into `home/dot_config/mise/config.toml`.

</details>

## Reminders (not automated)

<details>
<summary>Manual steps after bootstrap</summary>

- `make lint` (hooks installed during bootstrap)
- `make cli` — daily CLI formulae from `Brewfile.cli`
- `make apps` — GUI casks from `Brewfile.apps`
- `make ext` — VS Code and Cursor extensions from `Extfile` (+ per-editor deltas)
- `gh auth login`
- `atuin register`
- In tmux: `prefix + I` to install TPM plugins

</details>
