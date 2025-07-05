# Distribution Instructions

## Files Created

1. **rogue-asteroid.love** - Universal Love2D package (works on all platforms)
2. **rogue-asteroid-source.zip** - Source code package
3. **build.sh** - Cross-platform build script
4. **README.md** - Complete documentation

## Quick Distribution

### For End Users (Easiest)
Just distribute `builds/rogue-asteroid.love` with instructions:
- **Windows**: Download Love2D, drag .love file onto love.exe
- **Linux**: Install love2d package, run `love rogue-asteroid.love`  
- **macOS**: Download Love2D, drag .love file onto Love2D.app

### For Standalone Executables

#### Windows Standalone
1. Download Love2D Windows ZIP from https://love2d.org/
2. Extract to `builds/windows/`
3. In builds/windows/, run: `copy /b love.exe+../rogue-asteroid.love rogue-asteroid.exe`
4. Distribute the entire windows/ folder

#### Linux AppImage (Advanced)
1. Use love-release tool: `love-release -t linux64`
2. Or package with system Love2D installation

#### macOS App Bundle (Advanced)  
1. Download Love2D macOS
2. Copy Love2D.app to `Rogue-Asteroid.app`
3. Replace `Contents/Resources/game.love` with `rogue-asteroid.love`
4. Edit `Contents/Info.plist` to change app details

## Upload Platforms

- **itch.io**: Upload .love file + standalone builds
- **GitHub**: Create release with source + binaries
- **Game Jolt**: Upload platform-specific builds

The .love file is your universal distribution format!