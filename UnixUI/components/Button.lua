-- UI Button component
local Button = {}
Button.__index = Button

-- Create a new button
function Button.new(x, y, width, height, label)
    local self = setmetatable({}, Button)
    
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.label = label or "Button"
    self.enabled = true
    self.focused = false
    
    self.bgColor = colors.gray
    self.fgColor = colors.white
    self.focusedBg = colors.blue
    self.focusedFg = colors.white
    
    self.onClick = function() end
    
    return self
end

-- Draw the button
function Button:draw(renderer)
    local bgColor = self.focused and self.focusedBg or self.bgColor
    local fgColor = self.focusedFg
    
    -- Draw background
    renderer:drawFilledRect(self.x, self.y, self.width, self.height, bgColor)
    
    -- Draw border
    if self.focused then
        renderer:drawRect(self.x, self.y, self.width, self.height, colors.white)
    end
    
    -- Draw label centered
    local labelX = self.x + math.floor((self.width - #self.label) / 2)
    local labelY = self.y + math.floor(self.height / 2)
    renderer:write(labelX, labelY, self.label, fgColor, bgColor)
end

-- Check if point is within button
function Button:contains(x, y)
    return x >= self.x and x < self.x + self.width and
           y >= self.y and y < self.y + self.height
end

-- Set enabled state
function Button:setEnabled(enabled)
    self.enabled = enabled
end

-- Set focused state
function Button:setFocused(focused)
    self.focused = focused
end

-- Set click handler
function Button:setOnClick(callback)
    self.onClick = callback
end

-- Click the button
function Button:click()
    if self.enabled then
        self.onClick()
    end
end

return Button
