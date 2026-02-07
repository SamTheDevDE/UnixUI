# UnixUI Framework - Complete Guide

A lightweight, modular graphics framework for ComputerCraft: Tweaked.

## Table of Contents
1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Architecture](#architecture)
4. [Core Concepts](#core-concepts)
5. [API Reference](#api-reference)
6. [Advanced Usage](#advanced-usage)
7. [Examples](#examples)

## Installation

1. Place the `UnixUI` folder in your ComputerCraft scripts directory
2. Require the framework:
   ```lua
   local UnixUI = require("init")
   -- or import specific modules
   local Renderer = require("core.Renderer")
   ```

## Quick Start

### Minimal Example
```lua
local Renderer = require("core.Renderer")

local rend = Renderer.initialize()
rend:clear(colors.black)
rend:printAt(5, 5, "Hello World!", colors.white, colors.black)
rend:render()

os.pullEvent("key")
```

### Drawing Shapes
```lua
local rend = Renderer.initialize()
rend:clear(colors.black)

-- Filled rectangle
rend:drawFilledRect(5, 5, 20, 10, colors.blue)

-- Rectangle outline
rend:drawRect(3, 3, 24, 14, colors.white)

-- Line
rend:drawLine(5, 5, 25, 15, colors.red, "-")

-- Circle
rend:drawCircle(40, 8, 5, colors.green)

rend:render()
```

## Architecture

### Module Organization

```
UnixUI/
├── core/              Core rendering system
├── graphics/          Drawing primitives
├── components/        Reusable UI components
└── utils/             Helper utilities
```

### Data Flow

```
Input → Events/Input → Components → Renderer
                         ↓
                      Buffer
                         ↓
                      Output Device
```

## Core Concepts

### 1. Renderer
The main interface for drawing to the screen. It combines all other modules.

```lua
local Renderer = require("core.Renderer")
local rend = Renderer.new(outputDevice)
-- or auto-detect:
local rend = Renderer.initialize()
```

### 2. Buffer
Double-buffering system that prevents screen flicker.

```lua
local Buffer = require("core.Buffer")
local buf = Buffer.new(width, height)
buf:setChar(x, y, "A", colors.white, colors.black)
buf:render(outputDevice)
```

### 3. Shapes
Low-level drawing primitives.

```lua
local Shapes = require("graphics.Shapes")
Shapes.drawFilledRect(buffer, x, y, w, h, color)
Shapes.drawLine(buffer, x1, y1, x2, y2, color, char)
```

### 4. Text
Text rendering with formatting options.

```lua
local Text = require("graphics.Text")
Text.write(buffer, x, y, "Hello", colors.white, colors.black)
Text.printCentered(buffer, y, "Centered", colors.white, colors.black)
```

### 5. Components
Reusable UI elements with drawing and interaction support.

```lua
local Button = require("components.Button")
local btn = Button.new(x, y, width, height, "Label")
btn:draw(renderer)
```

## API Reference

### Renderer API

#### Methods
- `Renderer.new(output)` - Create with specific output
- `Renderer.initialize()` - Auto-detect and create
- `getSize()` - Get width and height
- `clear(color)` - Clear buffer
- `setChar(x, y, char, fgColor, bgColor)` - Set individual character
- `drawFilledRect(x, y, w, h, color)` - Filled rectangle
- `drawRect(x, y, w, h, color)` - Rectangle outline
- `drawLine(x1, y1, x2, y2, color, char)` - Line
- `drawCircle(cx, cy, radius, color)` - Circle
- `write(x, y, text, fgColor, bgColor)` - Write text
- `printAt(x, y, text, fgColor, bgColor)` - Print at position
- `printCentered(y, text, fgColor, bgColor)` - Centered text
- `printInBox(x, y, w, text, fgColor, bgColor)` - Text in box
- `render()` - Draw buffer to screen

### Components

#### Button
```lua
local btn = Button.new(x, y, width, height, label)
btn:setFocused(bool)
btn:setEnabled(bool)
btn:setOnClick(function() end)
btn:click()
btn:draw(renderer)
```

#### Panel
```lua
local panel = Panel.new(x, y, width, height, title)
panel:addChild(child)
panel:removeChild(child)
panel:getContentArea()
panel:setColors(bgColor, fgColor, titleBg, titleFg)
panel:draw(renderer)
```

### utilities

#### Device
```lua
Device.getOutput()        -- Get monitor or terminal
Device.hasMonitor()       -- Check for monitor
Device.getMonSize()       -- Get monitor size
Device.getTermSize()      -- Get terminal size
```

#### Colors
```lua
Colors.lighter(color)     -- Get lighter version
Colors.darker(color)      -- Get darker version
Colors.names              -- Color name table
```

#### Layout
```lua
Layout.center(itemSize, containerSize)
Layout.createGridLayout(x, y, cols, rows, cellW, cellH, spacing)
Layout.createAnchoredLayout(x, y, w, h)
Layout.getAvailableSpace(x, y, w, h, padding)
```

#### Input
```lua
Input.isMouseInBounds(mx, my, x, y, width, height)
Input.keys                -- Key code constants
Input.mouse               -- Mouse button constants
```

#### Events
```lua
Events.waitFor(eventType, timeout)
Events.waitForAny(eventTypes, timeout)
Events.createHandler()    -- Create event dispatcher
```

## Advanced Usage

### Creating Custom Components

```lua
local MyComponent = {}
MyComponent.__index = MyComponent

function MyComponent.new(x, y, width, height)
    local self = setmetatable({}, MyComponent)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    return self
end

function MyComponent:draw(renderer)
    -- Draw component
    renderer:drawFilledRect(self.x, self.y, self.width, self.height, colors.blue)
    renderer:write(self.x + 1, self.y + 1, "My Component", colors.white, colors.blue)
end

return MyComponent
```

### Interactive Application

```lua
local Renderer = require("core.Renderer")
local Input = require("utils.Input")
local Button = require("components.Button")

local rend = Renderer.initialize()
local inputHandler = Input.createHandler()

local buttons = {
    Button.new(5, 5, 15, 3, "Button 1"),
    Button.new(5, 9, 15, 3, "Button 2"),
    Button.new(5, 13, 15, 3, "Button 3"),
}

local currentSelection = 1

buttons[currentSelection]:setFocused(true)

while true do
    rend:clear(colors.black)
    
    for _, btn in ipairs(buttons) do
        btn:draw(rend)
    end
    
    rend:render()
    
    local event, a, b, c = os.pullEvent()
    
    if event == "key" then
        if a == keys.up then
            buttons[currentSelection]:setFocused(false)
            currentSelection = currentSelection > 1 and currentSelection - 1 or #buttons
            buttons[currentSelection]:setFocused(true)
        elseif a == keys.down then
            buttons[currentSelection]:setFocused(false)
            currentSelection = currentSelection < #buttons and currentSelection + 1 or 1
            buttons[currentSelection]:setFocused(true)
        elseif a == keys.enter then
            buttons[currentSelection]:click()
        elseif a == keys.escape then
            break
        end
    end
end

term.clear()
term.setCursorPos(1, 1)
```

## Examples

Run the included demos:
```bash
# Main demo
lua main.lua

# Example collection
lua example.lua
```

## Tips & Tricks

1. **Double Buffering**: All rendering is buffered - call `render()` once per frame
2. **Color Macros**: Use `colors.` constants for all color references
3. **Coordinate System**: (1,1) is top-left corner
4. **Efficiency**: Draw only what changes between frames
5. **Monitoring**: Requires monitor peripheral - auto-detected

## Performance

- Double buffering prevents flicker
- Efficient string manipulation for screen updates
- Only render on changes for better performance
- Buffer stays in memory across renders

## Limitations

- Limited to 16 colors (CC:Tweaked standard)
- Text-based graphics only
- Monitor size limited by peripheral capabilities
- No built-in animation frame limiting

## Troubleshooting

**Scripts won't start**: Check that all files are in the correct folder structure

**Monitor not detected**: Verify with `monitor` command in ComputerCraft

**Text gets cut off**: Check bounds - coordinates go from 1 to width/height

**Colors look wrong**: Use proper `colors.` constants, not raw numbers

## Contributing

Feel free to add more components, utilities, and features!

## License

Free to use and modify for ComputerCraft projects.
