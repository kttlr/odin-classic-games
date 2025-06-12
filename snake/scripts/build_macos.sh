#!/bin/bash

# macOS Build Script for Snake Game
# This script builds the Snake game for macOS using the Odin compiler

set -e  # Exit on any error

# Change to parent directory to find source files
cd "$(dirname "$0")/.."

echo "Building Snake for macOS..."

# Check if Odin compiler is available
if ! command -v odin &> /dev/null; then
    echo "Error: Odin compiler not found in PATH"
    echo "Please install Odin from: https://odin-lang.org/"
    exit 1
fi

# Create build directory if it doesn't exist
mkdir -p build

# Build the game
# -out: specifies output file path
# -o:speed: optimization for speed
# -no-bounds-check: disable bounds checking for better performance
# -target: specify target platform (darwin_amd64 for Intel Mac, darwin_arm64 for Apple Silicon)
echo "Compiling Snake..."

# Detect architecture and build accordingly
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    echo "Building for Apple Silicon (ARM64)..."
    odin build . -out:build/snake_macos_arm64 -o:speed -no-bounds-check -target:darwin_arm64
elif [[ "$ARCH" == "x86_64" ]]; then
    echo "Building for Intel Mac (x86_64)..."
    odin build . -out:build/snake_macos_x64 -o:speed -no-bounds-check -target:darwin_amd64
else
    echo "Unknown architecture: $ARCH"
    echo "Building for current platform..."
    odin build . -out:build/snake_macos -o:speed -no-bounds-check
fi

echo "Build completed successfully!"
echo "Executable created in build/ directory"

# Make the executable... executable (in case it's not already)
chmod +x build/snake_macos*

echo ""
echo "To run the game:"
if [[ "$ARCH" == "arm64" ]]; then
    echo "  ./build/snake_macos_arm64"
elif [[ "$ARCH" == "x86_64" ]]; then
    echo "  ./build/snake_macos_x64"
else
    echo "  ./build/snake_macos"
fi
