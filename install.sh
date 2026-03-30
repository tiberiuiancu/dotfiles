#!/bin/bash
set -euo pipefail

DOTFILES_REPO="git@github.com:tiberiuiancu/dotfiles.git"
CHEZMOI_BIN="$HOME/.local/bin"

# -------------------------------------------------------------------------
# This script must run in an interactive terminal so that chezmoi can prompt
# for per-machine config (e.g. has_sudo). Do not pipe directly into bash.
#
# Correct usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/tiberiuiancu/dotfiles/main/install.sh)
# -------------------------------------------------------------------------
if [ ! -t 0 ]; then
    echo "Error: run this script in an interactive terminal, not via curl | bash."
    echo ""
    echo "  bash <(curl -fsSL https://raw.githubusercontent.com/tiberiuiancu/dotfiles/main/install.sh)"
    exit 1
fi

mkdir -p "$CHEZMOI_BIN"
export PATH="$CHEZMOI_BIN:$PATH"

# Install chezmoi if not already available
if ! command -v chezmoi &>/dev/null; then
    echo "==> Installing chezmoi to $CHEZMOI_BIN ..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$CHEZMOI_BIN"
fi

echo "==> Initialising dotfiles from $DOTFILES_REPO ..."
chezmoi init --apply "$DOTFILES_REPO"

echo ""
echo "Done. Open a new terminal to pick up the new shell config."
