#!/usr/bin/env bash
set -euo pipefail

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "error: SwiftLint is not installed. Install via 'brew install swiftlint'" >&2
  exit 1
fi

CONFIG_FILE="$(git rev-parse --show-toplevel)/.swiftlint.yml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "error: .swiftlint.yml not found at repo root" >&2
  exit 1
fi

swiftlint lint --no-cache --config "$CONFIG_FILE" "$@"
