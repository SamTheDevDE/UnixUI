# UnixUI
A lightweight, modular graphics framework for ComputerCraft: Tweaked

## Features
- **Modular Packages** - Install only what you need:
  - Core - Rendering engine
  - Graphics - Drawing primitives
  - Components - UI widgets
  - Utilities - Helper functions
  - Demos - Example programs
  - Docs - Documentation
- **Buffered Rendering** - Efficient double-buffered graphics
- **Easy Installation** - Smart installer with package selection
- **Color Support** - Full CC:Tweaked palette support
- **Monitor Support** - Works with terminals and monitors

## Installation

### Quick Install (All Packages)
```bash
wget https://unixui.samthedev.de/install.lua install.lua
lua install.lua
```

### Custom Install
Run the installer and select which packages you want:
```bash
lua install.lua
```

Available packages:
- **installer** - Installation utility
- **core** - Core rendering (Buffer, Renderer)
- **graphics** - Graphics primitives (Shapes, Text)
- **components** - UI components (Button, Panel)
- **utils** - Utilities (Device, Colors, Events, Input, Layout, Screen)
- **demos** - Example programs
- **docs** - Documentation and guides
- **full** - Everything (recommended for first install)

## Quick Start

```lua
local Renderer = require("core.Renderer")

local rend = Renderer.initialize()
rend:clear(colors.black)
rend:drawRect(5, 5, 20, 10, colors.red)
rend:printAt(6, 6, "Hello!", colors.white, colors.red)
rend:render()

os.pullEvent("key")
```

## Documentation

After installing the **docs** package:
- [GUIDE.md](GUIDE.md) - Complete API documentation
- [STRUCTURE.md](STRUCTURE.md) - Project architecture

## Architecture

The framework is organized into modular packages:

```
UnixUI/
├── installer/        # Smart installer system
├── core/            # Buffer and Renderer
├── graphics/        # Shapes and Text rendering
├── components/      # UI components
├── utils/          # Helper utilities
├── demos/          # Example programs
└── docs/           # Documentation
```

Each package can be installed independently (respecting dependencies).

## Manifest Structure

The `manifest.json` file defines all packages and their files:
```json
{
  "name": "UnixUI",
  "version": "0.2.0",
  "packages": {
    "core": {
      "name": "Core",
      "description": "...",
      "files": [...],
      "dependencies": []
    },
    ...
  }
}
```

## Examples

Run the demos after installing:
```bash
lua demos/main.lua
lua demos/example.lua
```

## License

Free to use and modify for ComputerCraft projects.