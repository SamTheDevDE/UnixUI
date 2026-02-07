-- UI Panel component
local Panel = {}
Panel.__index = Panel

-- Create a new panel
function Panel.new(x, y, width, height, title)
    local self = setmetatable({}, Panel)
    
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.title = title or ""
    
    self.bgColor = colors.black
    self.fgColor = colors.white
    self.titleBg = colors.blue
    self.titleFg = colors.white
    
    self.children = {}
    
    return self
end

-- Draw the panel
function Panel:draw(renderer)
    -- Draw background
    renderer:drawFilledRect(self.x, self.y, self.width, self.height, self.bgColor)
    
    -- Draw border
    renderer:drawRect(self.x, self.y, self.width, self.height, self.fgColor)
    
    -- Draw title if present
    if self.title ~= "" then
        renderer:drawFilledRect(self.x + 1, self.y, self.width - 2, 1, self.titleBg)
        
        local titleX = self.x + 2
        local titleText = self.title:sub(1, self.width - 4)
        renderer:write(titleX, self.y, titleText, self.titleFg, self.titleBg)
    end
    
    -- Draw children
    for _, child in ipairs(self.children) do
        if child.draw then
            child:draw(renderer)
        end
    end
end

-- Add a child component
function Panel:addChild(child)
    table.insert(self.children, child)
end

-- Remove a child component
function Panel:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            break
        end
    end
end

-- Get content area (inside the border)
function Panel:getContentArea()
    local startY = self.y + (self.title ~= "" and 2 or 1)
    return self.x + 1, startY, self.width - 2, self.height - (startY - self.y) - 1
end

-- Set colors
function Panel:setColors(bgColor, fgColor, titleBg, titleFg)
    self.bgColor = bgColor
    self.fgColor = fgColor
    if titleBg then self.titleBg = titleBg end
    if titleFg then self.titleFg = titleFg end
end

return Panel
