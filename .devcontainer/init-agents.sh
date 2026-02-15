#!/usr/bin/env bash
set -euo pipefail

mkdir -p /commandhistory
touch /commandhistory/.zsh_history
chmod 600 /commandhistory/.zsh_history || true

mkdir -p "$HOME/.codex" "$HOME/.claude" "$HOME/.gemini"

if [ -f ".devcontainer/session-start.sh.template" ] && [ ! -f ".devcontainer/session-start.sh" ]; then
  cp .devcontainer/session-start.sh.template .devcontainer/session-start.sh
  chmod +x .devcontainer/session-start.sh
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config --global --add safe.directory "$(pwd)" || true
fi
