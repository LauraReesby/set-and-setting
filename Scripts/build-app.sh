#!/usr/bin/env bash
set -euo pipefail

DESTINATION=${DESTINATION:-""}
SCHEME=${SCHEME:-"Afterflow"}
PROJECT_PATH=${PROJECT_PATH:-"Afterflow.xcodeproj"}
DERIVED_DATA=${DERIVED_DATA:-"build/DerivedData"}
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --destination)
      DESTINATION="$2"
      shift 2
      ;;
    --scheme)
      SCHEME="$2"
      shift 2
      ;;
    --project)
      PROJECT_PATH="$2"
      shift 2
      ;;
    --derived-data)
      DERIVED_DATA="$2"
      shift 2
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

mkdir -p "$DERIVED_DATA/Logs/Build"

CMD=(xcodebuild build -project "$PROJECT_PATH" -scheme "$SCHEME" -derivedDataPath "$DERIVED_DATA")
if [[ -n "$DESTINATION" ]]; then
  CMD+=(-destination "$DESTINATION")
fi
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  CMD+=("${EXTRA_ARGS[@]}")
fi

"${CMD[@]}"
