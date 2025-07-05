#!/bin/bash

# Enhanced build script that downloads Love2D binaries
echo "=== Rogue Asteroid Enhanced Build Script ==="
echo ""

# Create directories
mkdir -p builds/windows
mkdir -p builds/linux
mkdir -p builds/macos

# Create .love file
echo "Creating .love package..."
zip -r builds/rogue-asteroid.love . -x "builds/*" "*.git*" "build.sh" "*.zip" "download-love2d.sh" "rogue-asteroid-source.zip"

echo "✓ Created builds/rogue-asteroid.love"
echo ""

echo "To create Windows standalone executable:"
echo "1. Download Love2D Windows (64-bit) from: https://github.com/love2d/love/releases"
echo "2. Extract the zip to builds/windows/"
echo "3. Run this command in builds/windows/:"
echo "   copy /b love.exe+../rogue-asteroid.love rogue-asteroid.exe"
echo ""

echo "Or use the download helper script:"
echo "./download-love2d.sh"