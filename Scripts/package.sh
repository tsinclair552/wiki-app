#!/bin/bash
# Package WikiApp as a macOS .app bundle with icon

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="WikiReader"
BUILD_DIR="$PROJECT_DIR/.build"

# Build
echo "→ Building..."
cd "$PROJECT_DIR"
swift build -c release

BINARY="$BUILD_DIR/release/WikiApp"
APP_BUNDLE="$PROJECT_DIR/build/$APP_NAME.app"
APP_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$APP_DIR/MacOS"
RESOURCES_DIR="$APP_DIR/Resources"

# Create bundle structure
echo "→ Creating .app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# Copy binary
cp "$BINARY" "$MACOS_DIR/$APP_NAME"

# Generate icon
echo "→ Generating icon (1024×1024)..."
MASTER_PNG="$BUILD_DIR/app-icon-master.png"
swift "$PROJECT_DIR/Scripts/render-icon.swift" "$MASTER_PNG" 2>&1

echo "→ Creating iconset..."
ICONSET_DIR="$BUILD_DIR/AppIcon.iconset"
mkdir -p "$ICONSET_DIR"

sips -z 16 16 "$MASTER_PNG" --out "$ICONSET_DIR/icon_16x16.png" &>/dev/null
sips -z 32 32 "$MASTER_PNG" --out "$ICONSET_DIR/icon_16x16@2x.png" &>/dev/null
cp "$ICONSET_DIR/icon_16x16@2x.png" "$ICONSET_DIR/icon_32x32.png"
sips -z 64 64 "$MASTER_PNG" --out "$ICONSET_DIR/icon_32x32@2x.png" &>/dev/null
sips -z 128 128 "$MASTER_PNG" --out "$ICONSET_DIR/icon_128x128.png" &>/dev/null
sips -z 256 256 "$MASTER_PNG" --out "$ICONSET_DIR/icon_128x128@2x.png" &>/dev/null
cp "$ICONSET_DIR/icon_128x128@2x.png" "$ICONSET_DIR/icon_256x256.png"
sips -z 512 512 "$MASTER_PNG" --out "$ICONSET_DIR/icon_256x256@2x.png" &>/dev/null
cp "$ICONSET_DIR/icon_256x256@2x.png" "$ICONSET_DIR/icon_512x512.png"
sips -z 1024 1024 "$MASTER_PNG" --out "$ICONSET_DIR/icon_512x512@2x.png" &>/dev/null

iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
rm -rf "$ICONSET_DIR" "$MASTER_PNG"

# Create Info.plist
echo "→ Creating Info.plist..."
cat > "$APP_DIR/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.tsinclair.wikireader</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>WikiReader</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo ""
echo "✅ Bundle created at: $APP_BUNDLE"
echo "   Drag to Applications or run: open $APP_BUNDLE"
