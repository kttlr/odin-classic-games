@echo off
REM Windows Build Script for Snake Game
REM This script builds the Snake game for Windows using the Odin compiler

REM Change to parent directory to find source files
cd /d "%~dp0\.."

echo Building Snake for Windows...

REM Check if Odin compiler is available
where odin >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Odin compiler not found in PATH
    echo Please install Odin from: https://odin-lang.org/
    pause
    exit /b 1
)

REM Create build directory if it doesn't exist
if not exist build mkdir build

REM Build the game
REM -out: specifies output file path
REM -o:speed: optimization for speed
REM -no-bounds-check: disable bounds checking for better performance
REM -target: specify target platform (windows_amd64 for 64-bit Windows)
echo Compiling Snake...

REM Build for 64-bit Windows
echo Building for Windows x64...
odin build . -out:build/snake_windows_x64.exe -o:speed -no-bounds-check -target:windows_amd64

if %errorlevel% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo Build completed successfully!
echo Executable created: build/snake_windows_x64.exe

echo.
echo To run the game:
echo   build\snake_windows_x64.exe

REM Optional: Build for 32-bit Windows (uncomment if needed)
REM echo Building for Windows x86...
REM odin build . -out:build/snake_windows_x86.exe -o:speed -no-bounds-check -target:windows_i386

pause
