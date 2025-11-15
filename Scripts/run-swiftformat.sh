#!/usr/bin/env bash
set -euo pipefail

if ! command -v swiftformat >/dev/null 2>&1; then
  echo "error: SwiftFormat is not installed. Install via 'brew install swiftformat'" >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
CONFIG_FILE="$REPO_ROOT/.swiftformat"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "error: .swiftformat not found at repo root" >&2
  exit 1
fi

swiftformat --config "$CONFIG_FILE" --cache ignore "$REPO_ROOT" "$@"
