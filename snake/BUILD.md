# Snake Game - Build Instructions

This document explains how to build the Snake game for different platforms using the Odin programming language.

## Prerequisites

1. **Odin Compiler**: Install the Odin compiler from [https://odin-lang.org/](https://odin-lang.org/)
   - Make sure `odin` is available in your system PATH
   - Test with: `odin version`

2. **Raylib**: The game uses Raylib, which should be included with your Odin installation
   - No additional setup required for Raylib

## Asset Embedding

This Snake game uses Odin's `#load` directive to embed assets directly into the binary:
- Audio files (`.ogg`, `.mp3`)
- Shader files (`.vert`, `.frag`)

**No manual asset copying is required** - all assets are baked into the executable at compile time.

## Build Scripts

### Build Scripts Location

All build scripts are located in the `scripts/` directory:

```
snake/
├── scripts/
│   ├── make_app.sh         # macOS .app bundle
│   ├── build_macos.sh      # macOS executable
│   ├── build_windows.bat   # Windows executable
│   └── Makefile           # Cross-platform builds
└── ...
```

### Quick Build (Current Platform)

```bash
# macOS - Double-clickable .app bundle
scripts/make_app.sh

# macOS - Command line executable
scripts/build_macos.sh

# Windows
scripts/build_windows.bat

# Cross-platform using Make
cd scripts && make
```

### Platform-Specific Builds

#### macOS App Bundle (Recommended)
```bash
scripts/make_app.sh
```
- Builds the game and packages it as a macOS .app bundle
- Uses your custom icon from `assets/snake-app.icns`
- Output: `build/Snake.app` (can be double-clicked from Finder)
- Can be dragged to Applications folder for installation

**Custom Icon Setup:**
1. Place your icon file at: `assets/snake-app.icns`
2. Icon should be in `.icns` format (macOS icon format)
3. Recommended size: 512x512 pixels or larger

#### macOS Executable
```bash
scripts/build_macos.sh
```
- Automatically detects your Mac's architecture (Intel or Apple Silicon)
- Creates optimized command-line executables
- Output: `build/snake_macos_x64` or `build/snake_macos_arm64`

#### Windows
```cmd
scripts/build_windows.bat
```
- Builds for Windows x64
- Output: `build/snake_windows_x64.exe`

### Cross-Platform Build (Using Make)

```bash
cd scripts
make cross-compile
```

This builds for all supported platforms:
- **macOS**: Intel x64, Apple Silicon ARM64
- **Windows**: x64, x86 (32-bit)
- **Linux**: x64, x86, ARM64

## Build Options

All build scripts use these optimizations:
- `-o:speed` - Optimization for speed
- `-no-bounds-check` - Disable bounds checking for better performance
- Platform-specific targeting for maximum compatibility

## Running the Game

After building, run the executable:

```bash
# macOS App Bundle (recommended)
open build/Snake.app
# or double-click Snake.app in Finder

# macOS/Linux executables
./build/snake_macos_arm64  # or appropriate variant
./build/snake_linux_x64

# Windows
build\snake_windows_x64.exe
```

## Game Controls

- **Arrow Keys** or **HJKL (Vim-style)**: Move snake
- **Enter**: Start game / Restart after game over
- **Close Window**: Quit game

## Troubleshooting

### "Odin compiler not found"
- Ensure Odin is installed and in your PATH
- Try running `odin version` to verify installation

### Build Fails
- Make sure you're in the correct directory (snake/)
- Check that all asset files exist in the `assets/` directory
- Verify Odin installation is complete and up-to-date

### Permission Denied (Unix-like systems)
```bash
chmod +x scripts/*.sh
```

## Features

- Classic Snake gameplay
- CRT shader effects for retro look
- Background music and sound effects
- High score persistence (saved to `highscore.json`)
- Smooth movement and collision detection

## File Structure
```
snake/
├── snake.odin          # Main game source code
├── assets/            # Game assets (embedded into binary)
│   ├── audio/         # Sound effects and music
│   ├── shaders/       # CRT effect shaders
│   └── snake-app.icns # Custom app icon (place here)
├── scripts/           # Build scripts
│   ├── make_app.sh    # macOS .app bundle creator
│   ├── build_macos.sh # macOS executable builder
│   ├── build_windows.bat # Windows executable builder
│   └── Makefile       # Cross-platform builds
├── build/             # Build output directory
└── BUILD.md          # This file
```

## Development

To modify the game:
1. Edit `snake.odin`
2. Run your preferred build script to recompile
3. Test the executable in the `build/` directory

The game will automatically embed any changes to assets when rebuilt.