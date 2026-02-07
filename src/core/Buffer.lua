-- Buffer management for double-buffering
local Buffer = {}
Buffer.__index = Buffer

-- Create a new buffer
function Buffer.new(width, height)
    local self = setmetatable({}, Buffer)
    
    self.width = width
    self.height = height
    self.text = {}
    self.fg = {}
    self.bg = {}
    
    self:clear(colors.black)
    
    return self
end

-- Clear the buffer
function Buffer:clear(bgColor)
    local bgChar = colors.toBlit(bgColor)
    
    for y = 1, self.height do
        self.text[y] = string.rep(" ", self.width)
        self.fg[y] = string.rep("0", self.width)
        self.bg[y] = string.rep(bgChar, self.width)
    end
end

-- Set a character in the buffer
function Buffer:setChar(x, y, char, textColor, bgColor)
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return false
    end
    
    local fgChar = colors.toBlit(textColor)
    local bgChar = colors.toBlit(bgColor)
    
    self.text[y] = self.text[y]:sub(1, x - 1) .. char .. self.text[y]:sub(x + 1)
    self.fg[y] = self.fg[y]:sub(1, x - 1) .. fgChar .. self.fg[y]:sub(x + 1)
    self.bg[y] = self.bg[y]:sub(1, x - 1) .. bgChar .. self.bg[y]:sub(x + 1)
    
    return true
end

-- Set a range of characters
function Buffer:setString(x, y, str, textColor, bgColor)
    for i = 1, #str do
        local char = str:sub(i, i)
        if not self:setChar(x + i - 1, y, char, textColor, bgColor) then
            break
        end
    end
end

-- Get a character from the buffer
function Buffer:getChar(x, y)
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return nil
    end
    return self.text[y]:sub(x, x)
end

-- Render the buffer to an output device
function Buffer:render(output)
    for y = 1, self.height do
        output.setCursorPos(1, y)
        output.blit(self.text[y], self.fg[y], self.bg[y])
    end
end

-- Get dimensions
function Buffer:getSize()
    return self.width, self.height
end

return Buffer
