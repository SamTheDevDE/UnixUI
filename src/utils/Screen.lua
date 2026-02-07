-- Screen utility functions for common operations
local Screen = {}

-- Hide cursor
function Screen.hideCursor()
    term.setCursorBlink(false)
end

-- Show cursor
function Screen.showCursor()
    term.setCursorBlink(true)
end

-- Save current terminal state
function Screen.saveState()
    local state = {}
    state.cursorX, state.cursorY = term.getCursorPos()
    state.textColor = term.getTextColor()
    state.bgColor = term.getBackgroundColor()
    return state
end

-- Restore terminal state
function Screen.restoreState(state)
    if state.cursorX and state.cursorY then
        term.setCursorPos(state.cursorX, state.cursorY)
    end
    if state.textColor then
        term.setTextColor(state.textColor)
    end
    if state.bgColor then
        term.setBackgroundColor(state.bgColor)
    end
end

-- Clear a rectangle of the screen
function Screen.clearRect(x, y, width, height, color)
    color = color or colors.black
    term.setBackgroundColor(color)
    
    for row = y, y + height - 1 do
        term.setCursorPos(x, row)
        term.write(string.rep(" ", width))
    end
end

-- Fade effect (simple flashing)
function Screen.fadeIn(steps)
    steps = steps or 3
    for i = 1, steps do
        sleep(0.1)
    end
end

-- Get terminal center position
function Screen.getCenterPos()
    local w, h = term.getSize()
    return math.floor(w / 2), math.floor(h / 2)
end

-- Draw a box outline using characters
function Screen.drawBox(x, y, width, height, color)
    local state = Screen.saveState()
    term.setTextColor(color)
    
    -- Top and bottom
    for i = 0, width - 1 do
        term.setCursorPos(x + i, y)
        term.write("-")
        term.setCursorPos(x + i, y + height - 1)
        term.write("-")
    end
    
    -- Left and right
    for i = 1, height - 2 do
        term.setCursorPos(x, y + i)
        term.write("|")
        term.setCursorPos(x + width - 1, y + i)
        term.write("|")
    end
    
    -- Corners
    term.setCursorPos(x, y)
    term.write("+")
    term.setCursorPos(x + width - 1, y)
    term.write("+")
    term.setCursorPos(x, y + height - 1)
    term.write("+")
    term.setCursorPos(x + width - 1, y + height - 1)
    term.write("+")
    
    Screen.restoreState(state)
end

return Screen
