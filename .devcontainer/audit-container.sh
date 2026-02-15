#!/usr/bin/env bash
set -euo pipefail

echo "== Allowed root =="
echo "${AGENT_ALLOWED_ROOT:-unset}"
echo

echo "== Mount targets (focused) =="
if command -v findmnt >/dev/null 2>&1; then
  findmnt -rn -o TARGET,SOURCE,FSTYPE | grep -E '^(/workspaces|/home/vscode|/commandhistory|/var/run/docker.sock)' || true
else
  awk '{print $5, $4}' /proc/self/mountinfo | grep -E '^(/workspaces|/home/vscode|/commandhistory|/var/run/docker.sock)' || true
fi
echo

echo "== Sensitive mount checks =="
for path in \
  "/var/run/docker.sock" \
  "$HOME/.ssh" \
  "$HOME/.aws" \
  "$HOME/.gnupg" \
  "$HOME/.config/gcloud" \
  "$HOME/.docker" \
  "$HOME/.kube"
do
  if command -v mountpoint >/dev/null 2>&1 && mountpoint -q "$path"; then
    echo "MOUNTED: $path"
  else
    echo "ok: $path not mounted"
  fi
done
echo

echo "== Listening TCP ports =="
if command -v ss >/dev/null 2>&1; then
  ss -lnt
else
  netstat -lnt 2>/dev/null || true
fi
echo

echo "== API key env vars (should be empty) =="
env | grep -E '^(OPENAI_API_KEY|ANTHROPIC_API_KEY|GEMINI_API_KEY)=' || true
