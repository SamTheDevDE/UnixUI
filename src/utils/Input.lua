-- Input handling utilities
local Input = {}

-- Create an input handler
function Input.createHandler()
    local handler = {}
    handler.keys = {}
    handler.lastMouse = {x = 0, y = 0}
    
    -- Check if a key is currently pressed
    function handler:isKeyPressed(keyCode)
        return self.keys[keyCode] or false
    end
    
    -- Process a key event
    function handler:processKeyEvent(eventType, keyCode)
        if eventType == "key" then
            self.keys[keyCode] = true
        elseif eventType == "key_up" then
            self.keys[keyCode] = false
        end
    end
    
    -- Process mouse event
    function handler:processMouseEvent(eventType, button, x, y)
        self.lastMouse = {x = x, y = y, button = button}
        return {x = x, y = y, button = button}
    end
    
    -- Clear key states
    function handler:clearKeys()
        self.keys = {}
    end
    
    return handler
end

-- Key code constants
Input.keys = {
    BACKSPACE = keys.backspace,
    TAB = keys.tab,
    ENTER = keys.enter,
    SHIFT = keys.lshift,
    CTRL = keys.lctrl,
    ALT = keys.lalt,
    ESC = keys.escape,
    SPACE = keys.space,
    UP = keys.up,
    DOWN = keys.down,
    LEFT = keys.left,
    RIGHT = keys.right,
    DELETE = keys.delete,
    A = keys.a,
    B = keys.b,
    C = keys.c,
    D = keys.d,
    E = keys.e,
    F = keys.f,
    W = keys.w,
    S = keys.s,
    -- ... add more as needed
}

-- Mouse button constants
Input.mouse = {
    LEFT = 1,
    RIGHT = 2,
    MIDDLE = 3,
}

-- Check if mouse position is within bounds
function Input.isMouseInBounds(mx, my, x, y, width, height)
    return mx >= x and mx < x + width and my >= y and my < y + height
end

return Input
