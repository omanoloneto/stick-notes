#!/bin/bash
# Package the SwiftPM executable into a minimal, locally-runnable .app bundle.
# Personal use: ad-hoc signed ("Sign to Run Locally"), no notarization, no sandbox.
#
# Usage: scripts/bundle.sh [release|debug]   (default: release)
set -euo pipefail

CONFIG="${1:-release}"
APP_NAME="Sticky Notes"
EXEC_NAME="StickyNotes"
BUNDLE_ID="co.akari.stickynotes"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build"
APP="$OUT/$APP_NAME.app"

echo "==> Building ($CONFIG)…"
swift build -c "$CONFIG" --product "$EXEC_NAME"
BIN="$(swift build -c "$CONFIG" --product "$EXEC_NAME" --show-bin-path)/$EXEC_NAME"

echo "==> Assembling bundle…"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/$EXEC_NAME"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>     <string>$APP_NAME</string>
    <key>CFBundleExecutable</key>      <string>$EXEC_NAME</string>
    <key>CFBundleIdentifier</key>      <string>$BUNDLE_ID</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key>         <string>1</string>
    <key>LSMinimumSystemVersion</key>  <string>14.0</string>
    <key>LSUIElement</key>             <true/>
    <key>NSHighResolutionCapable</key> <true/>
</dict>
</plist>
PLIST

echo "==> Ad-hoc signing…"
codesign --force --deep --sign - "$APP"

echo "==> Done: $APP"
echo "    Run:     open \"$APP\""
echo "    Install: cp -R \"$APP\" /Applications/"
