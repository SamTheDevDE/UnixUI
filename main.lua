-- Main demo of the UnixUI Graphics Framework
local Renderer = require("core.Renderer")
local Device = require("utils.Device")

-- Initialize renderer (will use monitor if available)
local rend = Renderer.initialize()

local running = true

while running do
    -- Clear screen with black background
    rend:clear(colors.black)

    -- Draw a title bar
    rend:drawFilledRect(1, 1, rend.width, 1, colors.blue)
    rend:write(2, 1, "UnixUI Graphics Demo - " .. (Device.hasMonitor() and "MONITOR" or "TERMINAL"), colors.white, colors.blue)

    -- Draw some shapes
    rend:drawRect(3, 3, 20, 8, colors.red)
    rend:drawFilledRect(25, 3, 15, 5, colors.green)

    -- Draw lines
    rend:drawLine(3, 12, 30, 12, colors.yellow, "-")
    rend:drawLine(3, 13, 30, 16, colors.cyan, "*")

    -- Draw text
    rend:printAt(3, 14, "Hello UnixUI!", colors.white, colors.black)
    rend:printAt(3, 15, "Simple Graphics", colors.white, colors.black)

    -- Draw a circle
    rend:drawCircle(50, 8, 4, colors.magenta)

    -- Status bar at bottom
    rend:drawFilledRect(1, rend.height, rend.width, 1, colors.gray)
    rend:write(2, rend.height, "Click anywhere or press any key to exit...", colors.white, colors.gray)

    -- Render everything to screen
    rend:render()

    -- Wait for input
    local event, a, b, c = os.pullEvent()
    
    if event == "key" then
        running = false
    elseif event == "mouse_click" then
        running = false
    end
end
