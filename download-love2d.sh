#!/bin/bash

# Download Love2D binaries for building standalone executables
echo "=== Love2D Download Helper ==="
echo ""

LOVE_VERSION="11.4"
LOVE_WIN_URL="https://github.com/love2d/love/releases/download/${LOVE_VERSION}/love-${LOVE_VERSION}-win64.zip"

echo "Downloading Love2D ${LOVE_VERSION} for Windows..."

if command -v wget >/dev/null 2>&1; then
    wget -O builds/love2d-windows.zip "$LOVE_WIN_URL"
elif command -v curl >/dev/null 2>&1; then
    curl -L -o builds/love2d-windows.zip "$LOVE_WIN_URL"
else
    echo "Error: Neither wget nor curl found. Please install one of them or download manually:"
    echo "$LOVE_WIN_URL"
    exit 1
fi

echo "Extracting to builds/windows/..."
cd builds
unzip -o love2d-windows.zip
mv love-${LOVE_VERSION}-win64/* windows/
rmdir love-${LOVE_VERSION}-win64
rm love2d-windows.zip
cd ..

echo "✓ Love2D Windows binaries downloaded to builds/windows/"
echo ""
echo "Creating Windows executable..."
cd builds/windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows environment
    copy /b love.exe+../rogue-asteroid.love rogue-asteroid.exe
else
    # Linux/Unix environment - use cat instead
    cat love.exe ../rogue-asteroid.love > rogue-asteroid.exe
fi
cd ../..

echo "✓ Created builds/windows/rogue-asteroid.exe"
echo ""
echo "Windows build complete! The builds/windows/ folder contains:"
echo "- rogue-asteroid.exe (standalone executable)"
echo "- All required DLL files"
echo ""
echo "You can now distribute the entire builds/windows/ folder to Windows users."