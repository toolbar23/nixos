#!/usr/bin/env bash
set -euo pipefail

# Build the custom installer ISO from the repo root.
# Defaults to daemon mode to avoid permission errors when /nix is root-owned.
export NIX_REMOTE="${NIX_REMOTE:-daemon}"

repo_root="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

exec nix --extra-experimental-features 'nix-command flakes' \
  build ".#installerIso"
