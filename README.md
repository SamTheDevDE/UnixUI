# UnixUI
A simple graphics framework for ComputerCraft: Tweaked

## Features
- **Buffered Rendering** - Efficient screen updates using double buffering
- **Drawing Primitives** - Rectangles, lines, and text rendering
- **Color Support** - Full CC:Tweaked color palette support
- **Monitor Support** - Works with both terminals and monitors
- **Simple API** - Easy to learn and use

## Quick Start

```lua
local Renderer = require("renderer")

-- Create a new renderer
local rend = Renderer.new()

-- Clear the screen
rend:clear(colors.black)

-- Draw a rectangle
rend:setTextColor(colors.red)
rend:drawRect(5, 5, 20, 10, colors.red)

-- Draw filled rectangle
rend:drawFilledRect(10, 8, 15, 5, colors.blue)

-- Draw text
rend:setTextColor(colors.white)
rend:setBackgroundColor(colors.black)
rend:printAt(3, 3, "Hello World!")

-- Render to screen
rend:render()
```

## API Reference

### Creating a Renderer
- `Renderer.new(output)` - Create a new renderer (output defaults to term)
- `Renderer.initialize()` - Auto-detect monitor or use terminal

### Drawing Methods
- `clear(color)` - Clear screen with color
- `drawRect(x, y, width, height, color)` - Draw rectangle outline
- `drawFilledRect(x, y, width, height, color)` - Draw filled rectangle
- `drawLine(x1, y1, x2, y2, color, char)` - Draw a line
- `printAt(x, y, text)` - Print text at position
- `write(text)` - Write text at cursor position
- `printLn(text)` - Print with newline

### Configuration
- `setTextColor(color)` - Set text color
- `setBackgroundColor(color)` - Set background color
- `setCursorPos(x, y)` - Set cursor position
- `render()` - Draw buffer to screen

### Properties
- `width` - Screen width
- `height` - Screen height
- `output` - Output device (terminal/monitor)

## Examples

Run the demo:
```
cd unixui
lua main.lua
```

Run interactive examples:
```
cd unixui
lua example.lua
```

## License
Feel free to use and modify as you like.