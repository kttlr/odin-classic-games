# Makefile for Snake Game (Odin)
# Cross-platform build system

# Default target
.PHONY: all clean help current macos windows linux

# Change to parent directory to find source files
PARENT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Variables
BUILD_DIR = ../build
ODIN_FLAGS = -o:speed -no-bounds-check
SOURCE_DIR = ..

# Default build for current platform
all: current

# Build for current platform
current:
	@echo "Building Snake for current platform..."
	@cd .. && mkdir -p build
	@cd .. && odin build . -out:build/snake $(ODIN_FLAGS)
	@echo "✓ Build complete: build/snake"

# macOS builds
macos: macos-x64 macos-arm64

macos-x64:
	@echo "Building Snake for macOS x64..."
	@cd .. && mkdir -p build
	@cd .. && odin build . -out:build/snake_macos_x64 $(ODIN_FLAGS) -target:darwin_amd64
	@echo "✓ Build complete: build/snake_macos_x64"

macos-arm64:
	@echo "Building Snake for macOS ARM64..."
	@cd .. && mkdir -p build
	@cd .. && odin build . -out:build/snake_macos_arm64 $(ODIN_FLAGS) -target:darwin_arm64
	@echo "✓ Build complete: build/snake_macos_arm64"

# Windows builds
windows: windows-x64 windows-x86

windows-x64:
	@echo "Building Snake for Windows x64..."
	@cd .. && mkdir -p build
	@cd .. && odin build . -out:build/snake_windows_x64.exe $(ODIN_FLAGS) -target:windows_amd64
	@echo "✓ Build complete: build/snake_windows_x64.exe"

windows-x86:
	@echo "Building Snake for Windows x86..."
	@cd .. && mkdir -p build
	@cd .. && odin build . -out:build/snake_windows_x86.exe $(ODIN_FLAGS) -target:windows_i386
	@echo "✓ Build complete: build/snake_windows_x86.exe"

# Linux builds
linux: linux-x64 linux-x86 linux-arm64

linux-x64:
	@echo "Building Snake for Linux x64..."
	@cd .. && mkdir -p build
	@cd .. && odin build . -out:build/snake_linux_x64 $(ODIN_FLAGS) -target:linux_amd64
	@echo "✓ Build complete: build/snake_linux_x64"

linux-x86:
	@echo "Building Snake for Linux x86..."
	@cd .. && mkdir -p build
	@cd .. && odin build . -out:build/snake_linux_x86 $(ODIN_FLAGS) -target:linux_i386
	@echo "✓ Build complete: build/snake_linux_x86"

linux-arm64:
	@echo "Building Snake for Linux ARM64..."
	@cd .. && mkdir -p build
	@cd .. && odin build . -out:build/snake_linux_arm64 $(ODIN_FLAGS) -target:linux_arm64
	@echo "✓ Build complete: build/snake_linux_arm64"

# Build for all platforms
cross-compile: macos windows linux
	@echo "✓ All cross-platform builds complete!"
	@cd .. && ls -la build/

# Clean build directory
clean:
	@echo "Cleaning build directory..."
	@cd .. && rm -rf build
	@echo "✓ Clean complete"

# Run the game (current platform build)
run: current
	@echo "Running Snake..."
	@cd .. && ./build/snake

# Help target
help:
	@echo "Snake Game Build System"
	@echo "======================"
	@echo ""
	@echo "Available targets:"
	@echo "  all            - Build for current platform (default)"
	@echo "  current        - Build for current platform"
	@echo "  run            - Build and run the game"
	@echo ""
	@echo "Platform-specific builds:"
	@echo "  macos          - Build for macOS (both architectures)"
	@echo "  macos-x64      - Build for macOS Intel"
	@echo "  macos-arm64    - Build for macOS Apple Silicon"
	@echo "  windows        - Build for Windows (both architectures)"
	@echo "  windows-x64    - Build for Windows 64-bit"
	@echo "  windows-x86    - Build for Windows 32-bit"
	@echo "  linux          - Build for Linux (all architectures)"
	@echo "  linux-x64      - Build for Linux 64-bit"
	@echo "  linux-x86      - Build for Linux 32-bit"
	@echo "  linux-arm64    - Build for Linux ARM64"
	@echo ""
	@echo "Other targets:"
	@echo "  cross-compile  - Build for all platforms"
	@echo "  clean          - Remove build directory"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "Note: Assets are embedded automatically using Odin's #load directive"
