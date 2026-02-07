# UnixUI Framework Structure

## Folder Layout

```
src/
├── core/              # Core renderer and buffer system
│   ├── Renderer.lua   # Main renderer class
│   └── Buffer.lua     # Double-buffer implementation
├── graphics/          # Drawing and rendering utilities
│   ├── Shapes.lua     # Rectangle, line, circle drawing
│   └── Text.lua       # Text rendering and formatting
├── components/        # Reusable UI components
│   ├── Button.lua     # Clickable button component
│   └── Panel.lua      # Container panel component
├── utils/             # Utility modules
│   ├── Device.lua     # Monitor/terminal detection
│   ├── Colors.lua     # Color utilities
│   ├── Events.lua     # Event handling (future)
│   └── Input.lua      # Input handling (future)
├── main.lua           # Main demo
└── example.lua        # Example usage and demonstrations
```

## Module Responsibilities

### Core (`src/core/`)
- **Renderer.lua**: High-level rendering API, combines all functionality
- **Buffer.lua**: Manages double-buffering for smooth rendering

### Graphics (`src/graphics/`)
- **Shapes.lua**: Drawing primitives - rectangles, lines, circles, etc.
- **Text.lua**: Text rendering including centering, wrapping, boxes

### Components (`src/components/`)
- **Button.lua**: Interactive button with click handling
- **Panel.lua**: Container with title and child components

### Utilities (`src/utils/`)
- **Device.lua**: Auto-detection of monitors vs terminals
- **Colors.lua**: Color manipulation and palette utilities
- **Events.lua** (future): Event processing and handling
- **Input.lua** (future): Keyboard/mouse input processing

## Usage Examples

### Basic Rendering
```lua
local Renderer = require("core.Renderer")
local rend = Renderer.initialize()

rend:clear(colors.black)
rend:drawRect(5, 5, 10, 5, colors.red)
rend:printAt(6, 6, "Hello!", colors.white, colors.red)
rend:render()
```

### Using Components
```lua
local Button = require("components.Button")
local Panel = require("components.Panel")

local panel = Panel.new(1, 1, 20, 10, "My Panel")
local button = Button.new(3, 3, 14, 2, "Click Me!")

button:setOnClick(function()
    print("Button clicked!")
end)

panel:addChild(button)
panel:draw(rend)
rend:render()
```

### Using Utilities
```lua
local Colors = require("utils.Colors")
local Device = require("utils.Device")

if Device.hasMonitor() then
    local w, h = Device.getMonSize()
    print("Monitor size: " .. w .. "x" .. h)
end

local lighter = Colors.lighter(colors.red) -- Returns colors.orange
```

## Design Principles

1. **Modularity**: Each module has a single responsibility
2. **Composition**: The Renderer combines shape, text, and buffer modules
3. **Extensibility**: Easy to add new components and utilities
4. **Simplicity**: Clean API that's easy to learn and use
5. **Performance**: Double-buffering prevents screen flicker

## Adding New Features

### New Component
1. Create `src/components/MyComponent.lua`
2. Inherit pattern from existing components
3. Include a `draw(renderer)` method

### New Graphics Function
1. Add to `src/graphics/Shapes.lua` or create new module
2. Follow the pattern: `Shapes.drawSomething(buffer, ...)`
3. Use `buffer:setChar()` to modify pixels

### New Utility
1. Create in `src/utils/`
2. Add to `init.lua` exports
3. Document usage in examples
