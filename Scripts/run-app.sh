#!/usr/bin/env bash
set -euo pipefail

DESTINATION=${DESTINATION:-"platform=iOS Simulator,name=iPhone 16"}
DEVICE_NAME=${DEVICE_NAME:-"iPhone 16"}
SCHEME=${SCHEME:-"Afterflow"}
PROJECT_PATH=${PROJECT_PATH:-"Afterflow.xcodeproj"}
DERIVED_DATA=${DERIVED_DATA:-"build/DerivedData"}
BUNDLE_ID=${BUNDLE_ID:-"com.lreesby.app.Afterflow"}
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --destination)
      DESTINATION="$2"
      shift 2
      ;;
    --device)
      DEVICE_NAME="$2"
      shift 2
      ;;
    --bundle-id)
      BUNDLE_ID="$2"
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

CMD=(xcodebuild build -project "$PROJECT_PATH" -scheme "$SCHEME" -destination "$DESTINATION" -derivedDataPath "$DERIVED_DATA")
if [[ ${#EXTRA_ARGS[@]} -gt 0 ]]; then
  CMD+=("${EXTRA_ARGS[@]}")
fi

"${CMD[@]}"

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/${SCHEME}.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "error: Unable to locate built app at $APP_PATH" >&2
  exit 1
fi

xcrun simctl boot "$DEVICE_NAME" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$DEVICE_NAME" -b >/dev/null 2>&1
xcrun simctl uninstall "$DEVICE_NAME" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install "$DEVICE_NAME" "$APP_PATH"
xcrun simctl launch "$DEVICE_NAME" "$BUNDLE_ID"
