-- Example usage of UnixUI Graphics Framework
local Renderer = require("core.Renderer")
local Button = require("components.Button")
local Panel = require("components.Panel")

-- Create a simple menu with buttons
local function drawMenu()
    local rend = Renderer.initialize()
    
    -- Create menu buttons
    local buttons = {
        Button.new(5, 6, 30, 2, "Start Game"),
        Button.new(5, 9, 30, 2, "Settings"),
        Button.new(5, 12, 30, 2, "Exit"),
    }
    
    local selectedButton = 1
    buttons[selectedButton]:setFocused(true)
    
    local running = true
    
    while running do
        rend:clear(colors.black)
        
        -- Title panel
        local titlePanel = Panel.new(1, 1, rend.width, 3, "Main Menu")
        titlePanel:setColors(colors.black, colors.white, colors.blue, colors.white)
        titlePanel:draw(rend)
        
        -- Draw buttons
        for i, btn in ipairs(buttons) do
            btn:draw(rend)
        end
        
        rend:printAt(2, rend.height, "Use arrows to select, click or press Enter", colors.white, colors.black)
        rend:render()
        
        -- Handle input
        local event, a, b, c = os.pullEvent()
        
        if event == "key" then
            if a == keys.up then
                buttons[selectedButton]:setFocused(false)
                selectedButton = selectedButton > 1 and selectedButton - 1 or #buttons
                buttons[selectedButton]:setFocused(true)
            elseif a == keys.down then
                buttons[selectedButton]:setFocused(false)
                selectedButton = selectedButton < #buttons and selectedButton + 1 or 1
                buttons[selectedButton]:setFocused(true)
            elseif a == keys.enter then
                running = false
            elseif a == keys.escape then
                running = false
            end
        elseif event == "mouse_click" then
            -- Check which button was clicked
            for i, btn in ipairs(buttons) do
                if btn:contains(b, c) then
                    selectedButton = i
                    running = false
                    break
                end
            end
        end
    end
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
    
    -- Create buttons
    local buttons = {
        Button.new(5, 5, 20, 3, "Button 1"),
        Button.new(5, 9, 20, 3, "Button 2"),
        Button.new(5, 13, 20, 3, "Button 3"),
    }
    
    local selectedButton = 1
    buttons[selectedButton]:setFocused(true)
    
    local buttonClicks = {0, 0, 0}
    
    -- Set click handlers
    for i, btn in ipairs(buttons) do
        btn:setOnClick(function()
            buttonClicks[i] = buttonClicks[i] + 1
        end)
    end
    
    local running = true
    
    while running do
        rend:clear(colors.black)
        
        -- Draw title
        rend:printAt(2, 1, "Button Demo - Click buttons or use keyboard", colors.white, colors.black)
        
        -- Draw buttons
        for i, btn in ipairs(buttons) do
            btn:draw(rend)
        end
        
        -- Draw click count
        rend:printAt(30, 5, "Clicks: " .. buttonClicks[1], colors.cyan, colors.black)
        rend:printAt(30, 9, "Clicks: " .. buttonClicks[2], colors.cyan, colors.black)
        rend:printAt(30, 13, "Clicks: " .. buttonClicks[3], colors.cyan, colors.black)
        
        rend:printAt(2, rend.height, "Use arrows/click buttons, ESC to exit", colors.white, colors.black)
        rend:render()
        
        -- Handle input
        local event, a, b, c = os.pullEvent()
        
        if event == "key" then
            if a == keys.up then
                buttons[selectedButton]:setFocused(false)
                selectedButton = selectedButton > 1 and selectedButton - 1 or #buttons
                buttons[selectedButton]:setFocused(true)
            elseif a == keys.down then
                buttons[selectedButton]:setFocused(false)
                selectedButton = selectedButton < #buttons and selectedButton + 1 or 1
                buttons[selectedButton]:setFocused(true)
            elseif a == keys.enter then
                buttons[selectedButton]:click()
            elseif a == keys.escape then
                running = false
            end
        elseif event == "mouse_click" then
            -- Check which button was clicked
            for i, btn in ipairs(buttons) do
                if btn:contains(b, c) then
                    btn:click()
                    break
                end
            end
        end
    end
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
