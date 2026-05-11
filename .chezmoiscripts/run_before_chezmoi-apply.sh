#!/bin/bash
set -euo pipefail

# Source secrets to make env vars available for chezmoi templates
if [ -f "$HOME/.config/zsh/secrets.env" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.config/zsh/secrets.env"
fi
