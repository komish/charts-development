#!/usr/bin/env bash
set -euo pipefail

# Required CLI tools; extend this list as needed.
REQUIRED_TOOLS=("gh" "curl" "jq" "rg" "base64")

# Verify each required tool is in PATH.
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    echo "❌ '$tool' is not installed or not in PATH." >&2
    exit 1
  fi
done

# Verify GitHub CLI is authenticated.
if ! gh auth status &>/dev/null; then
  echo "❌ GitHub CLI is not authenticated. Run 'gh auth login or set GH_TOKEN'." >&2
  exit 1
fi

# All checks passed; return systemMessage.
echo '{"systemMessage":"🟢 All pre-run checks passed: required tools available and GitHub CLI authenticated."}'
