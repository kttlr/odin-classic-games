# Windows Build Guide for Snake Game

This guide explains how to build the Snake game for Windows and create a distributable executable.

## Prerequisites

1. **Odin Compiler**: Install from [odin-lang.org](https://odin-lang.org/)
2. **Windows 10/11**: The script is designed for modern Windows
3. **Command Prompt**: Standard Windows command line

## Quick Start

```cmd
cd odin-classic-games\snake
scripts\make_app_windows.bat
```

## What the Build Script Does

The batch script will:
- ✅ Check for Odin compiler installation
- 🔨 Compile the game with optimizations for your CPU architecture
- 🎨 Embed a custom icon (if available)
- 📦 Create a portable executable in the `build/` folder
- 🚀 Generate a launcher script for easy distribution
- 📝 Create version info templates for future use

## Icon Setup

### Converting Your Icon

You currently have `assets/snake-app.icns` (macOS format). For Windows, you need `assets/snake-app.ico`.

#### Conversion Methods:

1. **Online Converters** (Easiest):
   - [convertio.co](https://convertio.co/icns-ico/)
   - [cloudconvert.com](https://cloudconvert.com/icns-to-ico)

2. **ImageMagick** (Command Line):
   ```bash
   magick convert assets/snake-app.icns assets/snake-app.ico
   ```

3. **GIMP** (Free Software):
   - Open `snake-app.icns` in GIMP
   - Export as `snake-app.ico`
   - Choose multiple sizes: 16x16, 32x32, 48x48, 256x256

### Icon Requirements
- **Format**: `.ico`
- **Location**: `assets/snake-app.ico`
- **Recommended sizes**: 16x16, 32x32, 48x48, 256x256 pixels
- **Color depth**: 32-bit with transparency

## Build Output

After running the build script, you'll find in the `build/` folder:

### Core Files
- **`Snake.exe`** - The main game executable (portable, no installation needed)
- **`Launch_Snake.bat`** - Launcher script for easy execution

### Additional Files
- **`version_info.rc`** - Resource file template for advanced executable metadata

## Distribution

### Simple Distribution
Just share the `Snake.exe` file - it's completely self-contained and portable.

### Advanced Distribution
Create a ZIP file with:
- `Snake.exe`
- `README.txt` (game instructions)
- `LICENSE.txt` (if applicable)

## Architecture Support

The build script automatically detects and builds for:
- **x64** (AMD64) - Most common
- **ARM64** - Windows on ARM devices
- **x86** - 32-bit systems (fallback)

## Troubleshooting

### Common Issues

1. **"Odin compiler not found"**
   - Install Odin from [odin-lang.org](https://odin-lang.org/)
   - Make sure `odin.exe` is in your PATH

2. **"Build failed"**
   - Check that all source files are present
   - Ensure you're in the correct directory
   - Try building without the icon first

3. **Missing icon doesn't break the build**
   - The game will still compile without a custom icon
   - It will just use the default Windows executable icon

### Advanced Customization

To customize the build further, you can modify the batch file variables:
- Company name and copyright
- Build optimization flags
- Target architecture
- Output filename

## Security Notes

### Windows Defender
The first time you run the executable, Windows Defender might flag it as unknown software since it's not digitally signed. This is normal for custom-built executables.

### Code Signing (Optional)
For distribution, consider:
1. Getting a code signing certificate
2. Signing the executable with `signtool.exe`
3. This eliminates security warnings for end users

## File Sizes

Typical build sizes:
- **Debug build**: ~8-12 MB
- **Optimized build**: ~3-5 MB
- **With embedded assets**: +~2 MB

The executable includes all game assets (sounds, shaders) embedded directly in the binary, making it truly portable.