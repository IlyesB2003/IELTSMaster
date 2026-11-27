#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$PROJECT_DIR/dist"
APP_NAME="IELTSMaster"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
DMG_PATH="$DIST_DIR/$APP_NAME.dmg"

echo "Building $APP_NAME (Release, ARM64)..."
cd "$PROJECT_DIR"
python3 Scripts/build_exams.py
python3 Scripts/build_drills.py
node Scripts/sync_native_content.mjs
CLANG_MODULE_CACHE_PATH=/tmp/clang-module-cache \
SWIFT_MODULECACHE_PATH=/tmp/swift-module-cache \
TMPDIR=/tmp \
swift build -c release --disable-sandbox --cache-path /tmp/spm-cache --product "$APP_NAME"

BIN_PATH="$(CLANG_MODULE_CACHE_PATH=/tmp/clang-module-cache SWIFT_MODULECACHE_PATH=/tmp/swift-module-cache TMPDIR=/tmp swift build -c release --disable-sandbox --cache-path /tmp/spm-cache --show-bin-path)/$APP_NAME"

if [[ ! -f "$BIN_PATH" ]]; then
  echo "Error: Release binary not found at $BIN_PATH"
  exit 1
fi

echo "Assembling macOS .app bundle..."
rm -rf "$DIST_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"
cp "$BIN_PATH" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp -R "$(dirname "$BIN_PATH")/IELTSMaster_IELTSCore.bundle" "$APP_BUNDLE/Contents/Resources/"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

echo "Generating macOS AppIcon.icns and in-app BrandLogo.png..."
CLANG_MODULE_CACHE_PATH=/tmp/clang-module-cache \
SWIFT_MODULECACHE_PATH=/tmp/swift-module-cache \
TMPDIR=/tmp \
swift "$PROJECT_DIR/Scripts/generate_icon.swift" \
  "$PROJECT_DIR/Sources/IELTSMaster/Resources/BrandLogo.png" \
  "$APP_BUNDLE/Contents/Resources/AppIcon.icns" \
  "$APP_BUNDLE/Contents/Resources/BrandLogo.png"

cat > "$APP_BUNDLE/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>IELTSMaster</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.ieltsmaster.macos</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>IELTS Master</string>
    <key>CFBundleDisplayName</key>
    <string>IELTS Master</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.education</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSMicrophoneUsageDescription</key>
    <string>IELTS Master records your voice locally for Speaking mock examinations and Pronunciation Lab exercises.</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>IELTS Master uses on-device speech recognition to transcribe your Speaking practice responses.</string>
</dict>
</plist>
PLIST

plutil -lint "$APP_BUNDLE/Contents/Info.plist"

echo "Signing app bundle (ad-hoc local signature)..."
codesign --force --deep --sign - "$APP_BUNDLE" || true

echo "Creating installable DMG at $DMG_PATH..."
DMG_STAGING="$DIST_DIR/dmg_staging"
mkdir -p "$DMG_STAGING"
cp -R "$APP_BUNDLE" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"
if hdiutil create -volname "IELTS Master" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_PATH"; then
  echo "DMG created: $DMG_PATH"
else
  echo "Notice: hdiutil unavailable in current sandbox environment; creating portable .zip archive instead."
  (cd "$DIST_DIR" && /usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP_NAME.app" "$APP_NAME-macOS-arm64.zip")
fi
rm -rf "$DMG_STAGING"

echo "Packaging complete:"
ls -lh "$DIST_DIR"
