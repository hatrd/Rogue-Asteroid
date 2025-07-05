# Windows Build Instructions

The Windows build directory is empty because you need Love2D binaries to create a standalone executable.

## Quick Setup

Run the download helper:
```bash
./download-love2d.sh
```

This will:
1. Download Love2D 11.4 Windows binaries
2. Extract them to builds/windows/
3. Create rogue-asteroid.exe automatically

## Manual Setup

1. Go to https://github.com/love2d/love/releases
2. Download `love-11.4-win64.zip`
3. Extract all files to `builds/windows/`
4. In builds/windows/, run:
   ```
   copy /b love.exe+../rogue-asteroid.love rogue-asteroid.exe
   ```

## What You Get

After building, `builds/windows/` will contain:
- `rogue-asteroid.exe` - Your game executable
- `love.dll`, `lua51.dll`, etc. - Required libraries
- `license.txt` - Love2D license

## Distribution

Zip the entire `builds/windows/` folder and share it. Windows users can run `rogue-asteroid.exe` directly without installing anything.

The standalone executable is about 10-15MB and includes everything needed to run the game.