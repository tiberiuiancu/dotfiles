# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Install on a new machine

```bash
bash <(curl -fsSL https://tiberiu.nl/setup.sh)
# or
bash <(wget -qO- https://tiberiu.nl/setup.sh)
```

> **Why `bash <(...)` instead of `curl | bash`?**
> The setup prompts for per-machine config (e.g. sudo access). That requires an
> interactive TTY, which `curl | bash` destroys. `bash <(...)` keeps it.
> `tiberiu.nl/setup.sh` handles this automatically via `exec < /dev/tty`, but
> `bash <(...)` is still the safer invocation.

On first run you will be asked:
- **Does this machine have sudo/root access?** — answer `false` on compute clusters

The script will then:
1. Install chezmoi to `~/.local/bin`
2. Clone this repo and run `chezmoi apply`
3. Install Homebrew (macOS) / packages via apt or pacman (Linux)
4. Install oh-my-zsh and zsh plugins
5. Install rustup and nvm
6. Install zsh (compile from source if no sudo)
7. Bootstrap `~/.zshrc`, `~/.zprofile`, `~/.zshenv`, `~/.bashrc`

### Prerequisites

- **macOS:** nothing, script handles everything
- **Linux with sudo:** `curl` or `wget`, a C compiler and `make` (only if zsh isn't already installed)
- **Linux without sudo (clusters):** same as above — zsh will be compiled into `~/.local/bin`

### SSH key not set up yet?

The install script uses SSH to clone the repo. If you haven't added your SSH
key to GitHub on the new machine yet, either do that first or run chezmoi
manually with HTTPS:

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Init with HTTPS (will prompt for GitHub credentials)
~/.local/bin/chezmoi init --apply https://github.com/tiberiuiancu/dotfiles.git
```

---

## Day-to-day usage

| Task | Command |
|------|---------|
| Pull latest dotfiles and apply | `chezmoi update` |
| Edit a managed file | `chezmoi edit ~/.config/zsh/zshrc.shared` |
| See what would change | `chezmoi diff` |
| Apply changes | `chezmoi apply` |
| Open source directory | `chezmoi cd` |

---

## Structure

```
.chezmoidata/
  packages.yaml         # Declarative package list (brew / apt / pacman)
.chezmoiscripts/
  run_once_before_install-homebrew.sh.tmpl
  run_once_before_install-rustup.sh.tmpl
  run_once_before_install-nvm.sh.tmpl
  run_once_before_install-zsh.sh.tmpl
  run_onchange_darwin-install-packages.sh.tmpl
  run_onchange_linux-install-packages.sh.tmpl
  run_once_after_setup-zsh-local-files.sh.tmpl
dot_config/
  zsh/
    zshrc.shared        # Shared interactive shell config (sourced by ~/.zshrc)
    zprofile.shared     # Shared login shell config (sourced by ~/.zprofile)
    zshenv.shared       # Shared env config (sourced by ~/.zshenv)
  bash/
    bashrc.shared       # Launches zsh; used on systems without chsh
.chezmoiexternal.toml   # oh-my-zsh + plugins declared as external git repos
```

The files under `~/.z*` and `~/.bashrc` are **not** managed by chezmoi —
they're machine-specific and simply source their `.shared` counterpart.

---

## Adding packages

Edit `.chezmoidata/packages.yaml` and run `chezmoi apply`. The `run_onchange`
scripts detect the change via a content hash and re-run the package manager.

```yaml
packages:
  darwin:
    brews:
      - your-new-package   # add here for macOS
  ubuntu:
    apt:
      - your-new-package   # add here for Ubuntu
  arch:
    pacman:
      - your-new-package   # add here for Arch
```

---

## Machine-specific config

Anything specific to one machine lives in the local (non-chezmoi) files:

| File | Purpose |
|------|---------|
| `~/.zshrc` | Machine-specific shell config |
| `~/.zprofile` | Machine-specific login config (PATH additions etc.) |
| `~/.config/chezmoi/chezmoi.toml` | Per-machine chezmoi data (e.g. `has_sudo`) |

Installers that append to `~/.zshrc` (conda, nvm, etc.) are harmless — chezmoi
never touches that file.

---

## Secrets (Bitwarden)

This repo uses [chezmoi's Bitwarden integration](https://chezmoi.io/user-guide/password-managers/bitwarden/)
for secrets. Before running `chezmoi apply` on a machine where templates reference
Bitwarden items, unlock the vault first:

```bash
export BW_SESSION=$(bw unlock --raw)
chezmoi apply
```
