-- Example usage of UnixUI Graphics Framework
local Renderer = require("core.Renderer")
local Button = require("components.Button")
local Panel = require("components.Panel")

-- Create a simple menu with buttons
local function drawMenu()
    local rend = Renderer.initialize()
    rend:clear(colors.black)
    
    -- Title panel
    local titlePanel = Panel.new(1, 1, rend.width, 3, "Main Menu")
    titlePanel:setColors(colors.black, colors.white, colors.blue, colors.white)
    titlePanel:draw(rend)
    
    -- Draw menu options
    local options = {"Start Game", "Settings", "Exit"}
    local startY = 6
    
    for i, option in ipairs(options) do
        rend:drawFilledRect(5, startY + (i-1)*3, 30, 2, colors.gray)
        rend:printAt(7, startY + (i-1)*3 + 1, option, colors.white, colors.gray)
    end
    
    rend:render()
end

-- Progress bar animation
local function progressBarDemo()
    local rend = Renderer.initialize()
    
    for progress = 0, 100, 5 do
        rend:clear(colors.black)
        
        rend:printAt(2, 5, "Loading...", colors.white, colors.black)
        
        -- Progress bar background
        rend:drawFilledRect(2, 7, 40, 3, colors.gray)
        
        -- Progress bar fill
        local fillWidth = math.floor(38 * progress / 100)
        rend:drawFilledRect(3, 8, fillWidth, 1, colors.lime)
        
        -- Percentage text
        rend:printAt(2, 11, progress .. "%", colors.white, colors.black)
        
        rend:render()
        sleep(0.1)
    end
    
    sleep(1)
end

-- Draw pattern with shapes
local function drawPattern()
    local rend = Renderer.initialize()
    rend:clear(colors.black)
    
    -- Draw colored boxes
    local colorList = {colors.red, colors.orange, colors.yellow, colors.lime, colors.cyan, colors.blue}
    
    for i = 1, 6 do
        rend:drawFilledRect(i*3, i*2, 8, 4, colorList[i])
    end
    
    -- Draw connecting lines
    rend:drawLine(1, 1, rend.width, rend.height, colors.white, "*")
    rend:drawLine(1, rend.height, rend.width, 1, colors.white, "*")
    
    rend:printAt(2, rend.height - 1, "Press any key...", colors.white, colors.black)
    
    rend:render()
    os.pullEvent("key")
end

-- Button demo
local function buttonDemo()
    local rend = Renderer.initialize()
    rend:clear(colors.black)
    
    -- Create buttons
    local btn1 = Button.new(5, 5, 15, 3, "Button 1")
    local btn2 = Button.new(5, 9, 15, 3, "Button 2")
    local btn3 = Button.new(5, 13, 15, 3, "Button 3")
    
    -- Set initial focus
    btn1:setFocused(true)
    
    -- Draw title
    rend:printAt(2, 1, "Button Demo (Use arrow keys)", colors.white, colors.black)
    
    -- Draw buttons
    btn1:draw(rend)
    btn2:draw(rend)
    btn3:draw(rend)
    
    rend:printAt(2, rend.height, "Press any key to exit...", colors.white, colors.black)
    rend:render()
    
    os.pullEvent("key")
end

-- Main menu
term.clear()
term.setCursorPos(1, 1)
print("UnixUI Graphics Framework Examples")
print("1. Menu Demo")
print("2. Progress Bar Demo")
print("3. Pattern Demo")
print("4. Button Demo")
print("")
write("Select demo (1-4): ")

local choice = read()

if choice == "1" then
    drawMenu()
    os.pullEvent("key")
elseif choice == "2" then
    progressBarDemo()
elseif choice == "3" then
    drawPattern()
elseif choice == "4" then
    buttonDemo()
else
    print("Invalid choice")
end

term.clear()
term.setCursorPos(1, 1)
print("Demo complete!")
