-- Example usage of UnixUI Graphics Framework
local Renderer = require("src.renderer")

-- Create a simple menu
local function drawMenu()
    local rend = Renderer.new()
    rend:clear(colors.black)
    
    -- Title
    rend:setBackgroundColor(colors.blue)
    rend:setTextColor(colors.white)
    rend:drawFilledRect(1, 1, rend.width, 3, colors.blue)
    rend:printAt(math.floor(rend.width/2) - 5, 2, "Main Menu")
    
    -- Menu options
    local options = {"Start Game", "Settings", "Exit"}
    local startY = 6
    
    for i, option in ipairs(options) do
        rend:setBackgroundColor(colors.gray)
        rend:setTextColor(colors.white)
        rend:drawFilledRect(5, startY + (i-1)*3, 30, 2, colors.gray)
        rend:printAt(7, startY + (i-1)*3 + 1, option)
    end
    
    rend:render()
end

-- Create a progress bar animation
local function progressBarDemo()
    local rend = Renderer.new()
    
    for progress = 0, 100, 5 do
        rend:clear(colors.black)
        
        rend:setTextColor(colors.white)
        rend:printAt(2, 5, "Loading...")
        
        -- Progress bar background
        rend:setBackgroundColor(colors.gray)
        rend:drawFilledRect(2, 7, 40, 3, colors.gray)
        
        -- Progress bar fill
        local fillWidth = math.floor(38 * progress / 100)
        rend:setBackgroundColor(colors.lime)
        rend:drawFilledRect(3, 8, fillWidth, 1, colors.lime)
        
        -- Percentage text
        rend:setBackgroundColor(colors.black)
        rend:printAt(2, 11, progress .. "%")
        
        rend:render()
        sleep(0.1)
    end
    
    sleep(1)
end

-- Create a simple drawing
local function drawPattern()
    local rend = Renderer.new()
    rend:clear(colors.black)
    
    -- Draw a pattern of colored boxes
    local colorList = {colors.red, colors.orange, colors.yellow, colors.lime, colors.cyan, colors.blue}
    
    for i = 1, 6 do
        rend:drawFilledRect(i*3, i*2, 8, 4, colorList[i])
    end
    
    -- Draw connecting lines
    rend:drawLine(1, 1, rend.width, rend.height, colors.white, "*")
    rend:drawLine(1, rend.height, rend.width, 1, colors.white, "*")
    
    rend:setBackgroundColor(colors.black)
    rend:setTextColor(colors.white)
    rend:printAt(2, rend.height - 1, "Press any key...")
    
    rend:render()
    os.pullEvent("key")
end

-- Run demos
print("UnixUI Graphics Framework Examples")
print("1. Menu Demo")
print("2. Progress Bar Demo")
print("3. Pattern Demo")
print("")
write("Select demo (1-3): ")

local choice = read()

if choice == "1" then
    drawMenu()
    os.pullEvent("key")
elseif choice == "2" then
    progressBarDemo()
elseif choice == "3" then
    drawPattern()
else
    print("Invalid choice")
end

term.clear()
term.setCursorPos(1, 1)
print("Demo complete!")
