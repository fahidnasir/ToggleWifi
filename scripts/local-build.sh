#!/bin/bash
set -e

echo "🔧 Building ToggleWifi.app..."

# Paths
DERIVED_DATA=build/DerivedData
BUILD_DIR=build/Release
DMG_ROOT=scripts/dmg-root
RELEASE_DIR=release

# Get version from Info.plist
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" ToggleWifi/Info.plist)
DMG_NAME="ToggleWifi-v$VERSION.dmg"
DMG_OUTPUT="$RELEASE_DIR/$DMG_NAME"

echo "📦 Version: $VERSION"
echo "📁 Cleaning previous builds..."
rm -rf "$DERIVED_DATA" "$BUILD_DIR" "$DMG_ROOT" "$RELEASE_DIR"
mkdir -p "$DMG_ROOT" "$RELEASE_DIR"

# Build the .app
xcodebuild -project ToggleWifi.xcodeproj \
  -scheme ToggleWifi \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA" \
  CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
  -destination 'platform=macOS,arch=arm64' \
  clean build

# Copy .app into DMG root
cp -R "$BUILD_DIR/ToggleWifi.app" "$DMG_ROOT/"

# Create the .dmg
echo "📀 Creating DMG..."
create-dmg \
  --volname "ToggleWifi $VERSION" \
  --window-pos 200 120 \
  --window-size 500 300 \
  --icon-size 100 \
  --icon "ToggleWifi.app" 125 150 \
  --hide-extension "ToggleWifi.app" \
  --app-drop-link 375 150 \
  "$DMG_OUTPUT" \
  "$DMG_ROOT"

# Cleanup
echo "🧹 Cleaning up..."
rm -rf "$DERIVED_DATA" "$BUILD_DIR" "$DMG_ROOT"

echo "✅ Done: $DMG_OUTPUT"

# Open the release directory
# open "$RELEASE_DIR"
