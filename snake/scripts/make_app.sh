#!/bin/bash

# Complete Snake Game App Builder for macOS
# This script builds the game, creates the .app bundle, and adds an icon

set -e  # Exit on any error

# Change to parent directory to find source files
cd "$(dirname "$0")/.."

APP_NAME="Snake"
APP_BUNDLE="${APP_NAME}.app"
BUNDLE_ID="com.example.snake"
VERSION="1.0.0"

echo "🐍 Building Snake Game for macOS"
echo "================================"

# Check if Odin compiler is available
if ! command -v odin &> /dev/null; then
    echo "❌ Error: Odin compiler not found in PATH"
    echo "Please install Odin from: https://odin-lang.org/"
    exit 1
fi

# Create build directory if it doesn't exist
mkdir -p build

# Clean up any existing app bundle
if [ -d "build/$APP_BUNDLE" ]; then
    echo "🧹 Removing existing app bundle..."
    rm -rf "build/$APP_BUNDLE"
fi

# Build the game executable
echo "🔨 Compiling Snake..."
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    echo "   Building for Apple Silicon (ARM64)..."
    odin build . -out:build/snake_executable -o:speed -no-bounds-check -target:darwin_arm64
elif [[ "$ARCH" == "x86_64" ]]; then
    echo "   Building for Intel Mac (x86_64)..."
    odin build . -out:build/snake_executable -o:speed -no-bounds-check -target:darwin_amd64
else
    echo "   Building for current platform..."
    odin build . -out:build/snake_executable -o:speed -no-bounds-check
fi

# Create app bundle structure
echo "📦 Creating app bundle structure..."
mkdir -p "build/$APP_BUNDLE/Contents/MacOS"
mkdir -p "build/$APP_BUNDLE/Contents/Resources"

# Move executable to the app bundle
mv build/snake_executable "build/$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Make executable
chmod +x "build/$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Create Info.plist
echo "📝 Creating Info.plist..."
cat > "build/$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>CFBundleDisplayName</key>
    <string>Snake Game</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.games</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024 Snake Game. All rights reserved.</string>
    <key>CFBundleIconFile</key>
    <string>snake-app</string>
</dict>
</plist>
EOF

# Create PkgInfo file
echo "APPL????" > "build/$APP_BUNDLE/Contents/PkgInfo"

# Copy custom icon
echo "🎨 Adding custom app icon..."
CUSTOM_ICON="assets/snake-app.icns"
ICON_DEST="build/$APP_BUNDLE/Contents/Resources/snake-app.icns"

if [ -f "$CUSTOM_ICON" ]; then
    cp "$CUSTOM_ICON" "$ICON_DEST"
    echo "✓ Custom icon copied from $CUSTOM_ICON"
else
    echo "⚠️  Custom icon not found at $CUSTOM_ICON"
    echo "   The app will use the default application icon."
    echo "   To add a custom icon, place your .icns file at: $CUSTOM_ICON"
fi

echo ""
echo "🎉 App bundle created successfully!"
echo "📍 Location: build/$APP_BUNDLE"
echo ""
echo "🚀 You can now:"
echo "   • Double-click build/$APP_BUNDLE to run the game"
echo "   • Drag build/$APP_BUNDLE to Applications folder to install"
echo "   • Right-click and 'Show Package Contents' to see the bundle structure"
echo ""
echo "⚠️  Security Note:"
echo "   On first run, macOS may show a security warning because the app"
echo "   isn't signed. Go to System Settings > Privacy & Security to allow it."
echo ""
echo "🎮 Game Controls:"
echo "   • Arrow Keys or HJKL: Move snake"
echo "   • Enter: Start game / Restart after game over"
echo ""

# Optional: Open the build folder in Finder
if command -v open &> /dev/null; then
    echo "📁 Opening build folder in Finder..."
    open build/
fi

echo "✅ App bundle creation complete!"
