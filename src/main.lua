-- Demo of the UnixUI Graphics Framework
local Renderer = require("src.renderer")

-- Initialize renderer
local rend = Renderer.new()

-- Clear screen with black background
rend:clear(colors.black)

-- Draw a title bar
rend:setBackgroundColor(colors.blue)
rend:setTextColor(colors.white)
rend:drawFilledRect(1, 1, rend.width, 1, colors.blue)
rend:printAt(2, 1, "UnixUI Graphics Demo")

-- Draw some shapes
rend:setTextColor(colors.red)
rend:drawRect(3, 3, 20, 8, colors.red)

rend:setBackgroundColor(colors.green)
rend:drawFilledRect(25, 3, 15, 5, colors.green)

rend:setTextColor(colors.yellow)
rend:drawLine(3, 12, 30, 12, colors.yellow, "-")
rend:drawLine(3, 13, 30, 16, colors.cyan, "*")

-- Draw some text
rend:setBackgroundColor(colors.black)
rend:setTextColor(colors.white)
rend:printAt(3, 14, "Hello UnixUI!")
rend:printAt(3, 15, "Simple Graphics")

-- Status bar at bottom
rend:setBackgroundColor(colors.gray)
rend:drawFilledRect(1, rend.height, rend.width, 1, colors.gray)
rend:setTextColor(colors.white)
rend:printAt(2, rend.height, "Press any key to exit...")

-- Render everything to screen
rend:render()

-- Wait for input
os.pullEvent("key")