@echo off
REM Complete Snake Game App Builder for Windows
REM This script builds the game, creates the exe, and adds an icon

setlocal enabledelayedexpansion

REM Change to parent directory to find source files
cd /d "%~dp0\.."

set APP_NAME=Snake
set VERSION=1.0.0
set COMPANY_NAME=Snake Game Studio
set COPYRIGHT=Copyright (C) 2024 Snake Game Studio. All rights reserved.

echo.
echo 🐍 Building Snake Game for Windows
echo ==================================

REM Check if Odin compiler is available
odin version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Odin compiler not found in PATH
    echo Please install Odin from: https://odin-lang.org/
    pause
    exit /b 1
)

REM Create build directory if it doesn't exist
if not exist "build" mkdir build

REM Clean up any existing executable
if exist "build\%APP_NAME%.exe" (
    echo 🧹 Removing existing executable...
    del "build\%APP_NAME%.exe"
)

REM Check for custom icon
set CUSTOM_ICON=assets\snake-app.ico
set ICON_FLAG=
if exist "%CUSTOM_ICON%" (
    set ICON_FLAG=-resource:%CUSTOM_ICON%
    echo 🎨 Custom icon found: %CUSTOM_ICON%
) else (
    echo ⚠️  Custom icon not found at %CUSTOM_ICON%
    echo    The executable will use the default Windows application icon.
    echo    To add a custom icon, convert your snake-app.icns to snake-app.ico
    echo    and place it at: %CUSTOM_ICON%
)

REM Build the game executable
echo 🔨 Compiling Snake for Windows...

REM Detect architecture
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo    Building for x64...
    set TARGET_FLAG=-target:windows_amd64
) else if "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    echo    Building for ARM64...
    set TARGET_FLAG=-target:windows_arm64
) else (
    echo    Building for x86...
    set TARGET_FLAG=-target:windows_i386
)

REM Build with optimizations and icon (if available)
odin build . -out:build/%APP_NAME%.exe -o:speed -no-bounds-check %TARGET_FLAG% %ICON_FLAG%

if %errorlevel% neq 0 (
    echo ❌ Build failed!
    pause
    exit /b 1
)

REM Create a simple batch launcher (optional, for debugging)
echo 📝 Creating launcher script...
(
echo @echo off
echo cd /d "%%~dp0"
echo start "" "%APP_NAME%.exe"
) > "build\Launch_%APP_NAME%.bat"

REM Create version info file (for future use with resource compiler)
echo 📝 Creating version info template...
(
echo #include ^<windows.h^>
echo.
echo VS_VERSION_INFO VERSIONINFO
echo FILEVERSION 1,0,0,0
echo PRODUCTVERSION 1,0,0,0
echo FILEFLAGSMASK VS_FFI_FILEFLAGSMASK
echo FILEFLAGS 0x0L
echo FILEOS VOS__WINDOWS32
echo FILETYPE VFT_APP
echo FILESUBTYPE VFT2_UNKNOWN
echo BEGIN
echo     BLOCK "StringFileInfo"
echo     BEGIN
echo         BLOCK "040904b0"
echo         BEGIN
echo             VALUE "CompanyName", "%COMPANY_NAME%"
echo             VALUE "FileDescription", "Snake Game - Classic arcade game"
echo             VALUE "FileVersion", "%VERSION%"
echo             VALUE "InternalName", "%APP_NAME%"
echo             VALUE "LegalCopyright", "%COPYRIGHT%"
echo             VALUE "OriginalFilename", "%APP_NAME%.exe"
echo             VALUE "ProductName", "Snake Game"
echo             VALUE "ProductVersion", "%VERSION%"
echo         END
echo     END
echo     BLOCK "VarFileInfo"
echo     BEGIN
echo         VALUE "Translation", 0x409, 1200
echo     END
echo END
) > "build\version_info.rc"

echo.
echo 🎉 Windows executable created successfully!
echo 📍 Location: build\%APP_NAME%.exe
echo.
echo 🚀 You can now:
echo    • Double-click build\%APP_NAME%.exe to run the game
echo    • Copy build\%APP_NAME%.exe anywhere to distribute the game
echo    • Use build\Launch_%APP_NAME%.bat for easy launching
echo.
echo 💡 Distribution Notes:
echo    • The .exe file is self-contained and portable
echo    • No installation required - just run the executable
echo    • Game saves high scores in the same directory as the executable
echo.
echo 🎮 Game Controls:
echo    • Arrow Keys or HJKL: Move snake
echo    • Enter: Start game / Restart after game over
echo.

REM Check if we can create an icon from the existing .icns
if exist "assets\snake-app.icns" if not exist "%CUSTOM_ICON%" (
    echo 🔧 Icon Conversion Help:
    echo    You have snake-app.icns but need snake-app.ico for Windows.
    echo    You can convert it using:
    echo    • Online converters like convertio.co or cloudconvert.com
    echo    • ImageMagick: magick convert snake-app.icns snake-app.ico
    echo    • GIMP: Open .icns file and export as .ico
    echo.
)

REM Optional: Open the build folder in Explorer
if exist "build\%APP_NAME%.exe" (
    echo 📁 Opening build folder in Explorer...
    start "" "build"
)

echo ✅ Windows executable creation complete!
echo.
pause
