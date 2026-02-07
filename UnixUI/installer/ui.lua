-- Lightweight installer UI utilities
-- Minimal UI components for the installer

local UI = {}

function UI.clearScreen()
    term.clear()
    term.setCursorPos(1, 1)
end

function UI.setColor(color)
    term.setTextColor(color)
end

function UI.resetColor()
    term.setTextColor(colors.white)
end

function UI.header(title, subtitle)
    UI.clearScreen()
    UI.setColor(colors.blue)
    print("=" .. string.rep("=", 38) .. "=")
    print("║" .. UI.centerText(title, 38) .. "║")
    if subtitle then
        print("║" .. UI.centerText(subtitle, 38) .. "║")
    end
    print("=" .. string.rep("=", 38) .. "=")
    UI.resetColor()
    print("")
end

function UI.centerText(text, width)
    width = width or 40
    local padding = math.floor((width - #text) / 2)
    return string.rep(" ", padding) .. text .. string.rep(" ", width - padding - #text)
end

function UI.menu(title, options)
    local selected = 1
    
    while true do
        UI.header(title)
        print("")
        
        for i, opt in ipairs(options) do
            if i == selected then
                UI.setColor(colors.black)
                term.setBackgroundColor(colors.cyan)
                print("▶ " .. opt.text)
                UI.resetColor()
                term.setBackgroundColor(colors.black)
                if opt.desc then
                    print("  " .. opt.desc)
                end
            else
                UI.setColor(colors.white)
                print("  " .. opt.text)
                if opt.desc then
                    print("  " .. opt.desc)
                end
            end
            print("")
        end
        
        UI.setColor(colors.gray)
        print("Use UP/DOWN arrows to select, ENTER to confirm")
        UI.resetColor()
        
        local event, key = os.pullEvent("key")
        
        if key == keys.up then
            selected = selected > 1 and selected - 1 or #options
        elseif key == keys.down then
            selected = selected < #options and selected + 1 or 1
        elseif key == keys.enter then
            return options[selected]
        end
    end
end

function UI.confirm(message)
    UI.clearScreen()
    UI.setColor(colors.yellow)
    print(message)
    UI.resetColor()
    print("")
    print("Press ENTER to continue or ESC to cancel")
    
    while true do
        local event, key = os.pullEvent("key")
        if key == keys.enter then
            return true
        elseif key == keys.escape then
            return false
        end
    end
end

function UI.message(title, message)
    UI.header(title, message)
    print("")
    print("Press any key to continue...")
    os.pullEvent("key")
end

function UI.error(title, message)
    UI.clearScreen()
    UI.setColor(colors.red)
    print("!" .. string.rep("!", 38) .. "!")
    print("║" .. UI.centerText(title, 38) .. "║")
    print("!" .. string.rep("!", 38) .. "!")
    UI.resetColor()
    print("")
    print(message)
    print("")
    print("Press any key to exit...")
    os.pullEvent("key")
end

function UI.progress(title, current, total)
    UI.header(title)
    print("")
    
    local percentage = math.floor((current / total) * 100)
    local barWidth = 30
    local filledWidth = math.floor((current / total) * barWidth)
    
    print("Progress: [" .. string.rep("█", filledWidth) .. string.rep("░", barWidth - filledWidth) .. "] " .. percentage .. "%")
    print("")
    print("Downloaded: " .. current .. "/" .. total)
end

return UI
