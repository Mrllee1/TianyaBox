#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEVICE_ID="${1:?usage: build_and_install.sh DEVICE_ID}"
DERIVED_DATA="$PROJECT_ROOT/Build/DerivedData"
RUNTIME_FRAMEWORKS="${TEMPMAIL_RUNTIME_FRAMEWORKS:-$PROJECT_ROOT/Build/Runtime/Frameworks}"
: "${TEMPMAIL_SIGNING_IDENTITY:?Set TEMPMAIL_SIGNING_IDENTITY to a local development certificate SHA-1}"
: "${TEMPMAIL_DEVICE_PROFILE:?Set TEMPMAIL_DEVICE_PROFILE to the development mobileprovision path}"
if [[ ! -f "$RUNTIME_FRAMEWORKS/PBPlayerKit.framework/PBPlayerKit" || ! -f "$RUNTIME_FRAMEWORKS/Flutter.framework/Flutter" ]]; then
  echo "Stage the verified runtime frameworks into $RUNTIME_FRAMEWORKS first." >&2
  exit 2
fi
if [[ ! -f "$PROJECT_ROOT/Pods/Pods.xcodeproj/project.pbxproj" ]]; then
  echo "Run pod install in $PROJECT_ROOT first." >&2
  exit 3
fi
FLUTTER_FRAMEWORK_SOURCE="${TEMPMAIL_FLUTTER_FRAMEWORK_SOURCE:-${FLUTTER_ROOT:-$HOME/flutter}/bin/cache/artifacts/engine/ios/Flutter.xcframework/ios-arm64/Flutter.framework}"
python3 "$PROJECT_ROOT/Tools/prepare_flutter_simulator_runtime.py" "$FLUTTER_FRAMEWORK_SOURCE" "$RUNTIME_FRAMEWORKS/Flutter.framework"
python3 "$PROJECT_ROOT/Tools/stage_flutter_guest_plugins.py"   "${PORNHUB_GUEST_IPA:-$PROJECT_ROOT/Artifacts/Guests/tianya-20.0.0-357.ipa}" "$RUNTIME_FRAMEWORKS"
xcodebuild -project "$PROJECT_ROOT/Pods/Pods.xcodeproj" -scheme ZIPFoundation \
  -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath "$PROJECT_ROOT/Build/ZIPFoundationDerivedData" \
  IPHONEOS_DEPLOYMENT_TARGET=15.0 build

ditto "$PROJECT_ROOT/build/Release-iphoneos/ZIPFoundation/ZIPFoundation.framework" \
  "$RUNTIME_FRAMEWORKS/ZIPFoundation.framework"
xcodebuild -project "$PROJECT_ROOT/Runner.xcodeproj" -scheme Runner \
  -configuration Release -destination 'generic/platform=iOS' -derivedDataPath "$DERIVED_DATA" \
  "FRAMEWORK_SEARCH_PATHS=\$(inherited) $RUNTIME_FRAMEWORKS" \
  'OTHER_LDFLAGS=$(inherited) -framework ZIPFoundation' \
  "TEMPMAIL_CATALOG_BASE_URL=${TEMPMAIL_CATALOG_BASE_URL:-https://3601.help}" \
  "TEMPMAIL_CLIENT_AES_KEY=${TEMPMAIL_CLIENT_AES_KEY:-}" \
  "TEMPMAIL_ASSET_AES_KEY=${TEMPMAIL_ASSET_AES_KEY:-}" \
  "TEMPMAIL_ASSET_AES_IV=${TEMPMAIL_ASSET_AES_IV:-}" \
  SWIFT_ENABLE_EXPLICIT_MODULES=NO CODE_SIGNING_ALLOWED=NO build
HOST_APP="$DERIVED_DATA/Build/Products/Release-iphoneos/TempMail.app"
ditto "$RUNTIME_FRAMEWORKS" "$HOST_APP/Frameworks"
python3 "$SCRIPT_DIR/sign_device_build.py" "$HOST_APP" "$TEMPMAIL_DEVICE_PROFILE" "$TEMPMAIL_SIGNING_IDENTITY"
xcrun devicectl device install app --device "$DEVICE_ID" "$HOST_APP"
xcrun devicectl device process launch --device "$DEVICE_ID" --terminate-existing com.tianya.tempmail
echo "TIANYABOX_HOST_OK device=$DEVICE_ID bundle=com.tianya.tempmail host_app=$HOST_APP"
