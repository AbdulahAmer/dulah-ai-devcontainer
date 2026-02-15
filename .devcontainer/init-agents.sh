#!/usr/bin/env bash
set -euo pipefail

umask 077

cwd="$(pwd -P)"
allowed_root="${AGENT_ALLOWED_ROOT:-}"

if [ -n "$allowed_root" ]; then
  if echo "$allowed_root" | grep -q '\${'; then
    # Fall back when placeholder expansion did not run.
    allowed_root="$cwd"
  elif command -v realpath >/dev/null 2>&1; then
    allowed_root="$(realpath -m "$allowed_root")"
  fi

  allowed_root="${allowed_root%/}"
  export AGENT_ALLOWED_ROOT="$allowed_root"

  case "${cwd}/" in
    "${allowed_root}/"*) ;;
    *)
      echo "Refusing init outside AGENT_ALLOWED_ROOT ($allowed_root)"
      exit 1
      ;;
  esac
fi

mkdir -p /commandhistory
touch /commandhistory/.zsh_history
chmod 600 /commandhistory/.zsh_history || true

for agent_dir in "$HOME/.codex" "$HOME/.claude" "$HOME/.gemini"; do
  mkdir -p "$agent_dir"
  chmod 700 "$agent_dir" || true
done

for personal_path in \
  "/var/run/docker.sock" \
  "$HOME/.ssh" \
  "$HOME/.aws" \
  "$HOME/.gnupg" \
  "$HOME/.config/gcloud" \
  "$HOME/.docker" \
  "$HOME/.kube"
do
  if command -v mountpoint >/dev/null 2>&1 && mountpoint -q "$personal_path"; then
    echo "Refusing startup: personal credential mount detected at $personal_path"
    exit 1
  fi
done

if [ -f ".devcontainer/session-start.sh.template" ] && [ ! -f ".devcontainer/session-start.sh" ]; then
  cp .devcontainer/session-start.sh.template .devcontainer/session-start.sh
fi
chmod 700 .devcontainer/session-start.sh 2>/dev/null || true

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config --global --add safe.directory "$(pwd)" || true
fi
