-- Simple Graphics Framework for ComputerCraft: Tweaked
local Renderer = {}
Renderer.__index = Renderer

-- Initialize a new renderer instance
function Renderer.new(output)
    local self = setmetatable({}, Renderer)
    
    -- Use provided output or default to term
    self.output = output or term.current()
    self.width, self.height = self.output.getSize()
    
    -- Create buffer for efficient rendering
    self.buffer = {}
    self.colorBuffer = {}
    self.bgColorBuffer = {}
    
    for y = 1, self.height do
        self.buffer[y] = string.rep(" ", self.width)
        self.colorBuffer[y] = string.rep("0", self.width)
        self.bgColorBuffer[y] = string.rep("f", self.width)
    end
    
    -- Default colors
    self.currentTextColor = colors.white
    self.currentBgColor = colors.black
    
    return self
end

-- Get monitor or terminal size
function Renderer.getMonSize()
    local mon = peripheral.find("monitor")
    if mon then
        return mon.getSize()
    end
    return nil
end

function Renderer.getTermSize()
    return term.getSize()
end

-- Clear the screen
function Renderer:clear(color)
    color = color or self.currentBgColor
    local colorChar = colors.toBlit(color)
    
    for y = 1, self.height do
        self.buffer[y] = string.rep(" ", self.width)
        self.colorBuffer[y] = string.rep("0", self.width)
        self.bgColorBuffer[y] = string.rep(colorChar, self.width)
    end
end

-- Set cursor position
function Renderer:setCursorPos(x, y)
    self.cursorX = x
    self.cursorY = y
end

-- Set text color
function Renderer:setTextColor(color)
    self.currentTextColor = color
end

-- Set background color
function Renderer:setBackgroundColor(color)
    self.currentBgColor = color
end

-- Write text at current cursor position
function Renderer:write(text)
    if not self.cursorY or self.cursorY < 1 or self.cursorY > self.height then
        return
    end
    
    local x = self.cursorX or 1
    local y = self.cursorY
    
    for i = 1, #text do
        if x >= 1 and x <= self.width then
            local char = text:sub(i, i)
            local textColorChar = colors.toBlit(self.currentTextColor)
            local bgColorChar = colors.toBlit(self.currentBgColor)
            
            self.buffer[y] = self.buffer[y]:sub(1, x - 1) .. char .. self.buffer[y]:sub(x + 1)
            self.colorBuffer[y] = self.colorBuffer[y]:sub(1, x - 1) .. textColorChar .. self.colorBuffer[y]:sub(x + 1)
            self.bgColorBuffer[y] = self.bgColorBuffer[y]:sub(1, x - 1) .. bgColorChar .. self.bgColorBuffer[y]:sub(x + 1)
        end
        x = x + 1
    end
    
    self.cursorX = x
end

-- Print text at position
function Renderer:printAt(x, y, text)
    self:setCursorPos(x, y)
    self:write(text)
end

-- Print text with newline
function Renderer:printLn(text)
    self:write(text)
    if self.cursorY then
        self.cursorY = self.cursorY + 1
        self.cursorX = 1
    end
end

-- Draw a filled rectangle
function Renderer:drawFilledRect(x, y, width, height, color)
    color = color or self.currentBgColor
    local bgColorChar = colors.toBlit(color)
    
    for dy = 0, height - 1 do
        local row = y + dy
        if row >= 1 and row <= self.height then
            for dx = 0, width - 1 do
                local col = x + dx
                if col >= 1 and col <= self.width then
                    self.buffer[row] = self.buffer[row]:sub(1, col - 1) .. " " .. self.buffer[row]:sub(col + 1)
                    self.bgColorBuffer[row] = self.bgColorBuffer[row]:sub(1, col - 1) .. bgColorChar .. self.bgColorBuffer[row]:sub(col + 1)
                end
            end
        end
    end
end

-- Draw a rectangle outline
function Renderer:drawRect(x, y, width, height, color)
    color = color or self.currentTextColor
    local char = "#"
    local textColorChar = colors.toBlit(color)
    
    -- Top and bottom
    for dx = 0, width - 1 do
        local col = x + dx
        -- Top
        if y >= 1 and y <= self.height and col >= 1 and col <= self.width then
            self.buffer[y] = self.buffer[y]:sub(1, col - 1) .. char .. self.buffer[y]:sub(col + 1)
            self.colorBuffer[y] = self.colorBuffer[y]:sub(1, col - 1) .. textColorChar .. self.colorBuffer[y]:sub(col + 1)
        end
        -- Bottom
        local bottom = y + height - 1
        if bottom >= 1 and bottom <= self.height and col >= 1 and col <= self.width then
            self.buffer[bottom] = self.buffer[bottom]:sub(1, col - 1) .. char .. self.buffer[bottom]:sub(col + 1)
            self.colorBuffer[bottom] = self.colorBuffer[bottom]:sub(1, col - 1) .. textColorChar .. self.colorBuffer[bottom]:sub(col + 1)
        end
    end
    
    -- Left and right
    for dy = 1, height - 2 do
        local row = y + dy
        -- Left
        if row >= 1 and row <= self.height and x >= 1 and x <= self.width then
            self.buffer[row] = self.buffer[row]:sub(1, x - 1) .. char .. self.buffer[row]:sub(x + 1)
            self.colorBuffer[row] = self.colorBuffer[row]:sub(1, x - 1) .. textColorChar .. self.colorBuffer[row]:sub(x + 1)
        end
        -- Right
        local right = x + width - 1
        if row >= 1 and row <= self.height and right >= 1 and right <= self.width then
            self.buffer[row] = self.buffer[row]:sub(1, right - 1) .. char .. self.buffer[row]:sub(right + 1)
            self.colorBuffer[row] = self.colorBuffer[row]:sub(1, right - 1) .. textColorChar .. self.colorBuffer[row]:sub(right + 1)
        end
    end
end

-- Draw a line
function Renderer:drawLine(x1, y1, x2, y2, color, char)
    color = color or self.currentTextColor
    char = char or "-"
    local textColorChar = colors.toBlit(color)
    
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = x1 < x2 and 1 or -1
    local sy = y1 < y2 and 1 or -1
    local err = dx - dy
    
    while true do
        if x1 >= 1 and x1 <= self.width and y1 >= 1 and y1 <= self.height then
            self.buffer[y1] = self.buffer[y1]:sub(1, x1 - 1) .. char .. self.buffer[y1]:sub(x1 + 1)
            self.colorBuffer[y1] = self.colorBuffer[y1]:sub(1, x1 - 1) .. textColorChar .. self.colorBuffer[y1]:sub(x1 + 1)
        end
        
        if x1 == x2 and y1 == y2 then break end
        
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x1 = x1 + sx
        end
        if e2 < dx then
            err = err + dx
            y1 = y1 + sy
        end
    end
end

-- Render the buffer to screen
function Renderer:render()
    for y = 1, self.height do
        self.output.setCursorPos(1, y)
        self.output.blit(self.buffer[y], self.colorBuffer[y], self.bgColorBuffer[y])
    end
end

-- Convenience method: initialize with auto-detection
function Renderer.initialize(size)
    local output = peripheral.find("monitor") or term.current()
    return Renderer.new(output)
end

return Renderer