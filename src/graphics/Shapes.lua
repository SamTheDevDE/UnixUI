-- Drawing shapes on buffer
local Shapes = {}

-- Draw a filled rectangle
function Shapes.drawFilledRect(buffer, x, y, width, height, color)
    local bgChar = colors.toBlit(color)
    
    for dy = 0, height - 1 do
        local row = y + dy
        if row >= 1 and row <= buffer.height then
            for dx = 0, width - 1 do
                local col = x + dx
                if col >= 1 and col <= buffer.width then
                    buffer:setChar(col, row, " ", colors.white, color)
                end
            end
        end
    end
end

-- Draw a rectangle outline
function Shapes.drawRect(buffer, x, y, width, height, color)
    local char = "#"
    
    -- Top and bottom
    for dx = 0, width - 1 do
        local col = x + dx
        -- Top
        if y >= 1 and y <= buffer.height and col >= 1 and col <= buffer.width then
            buffer:setChar(col, y, char, color, colors.black)
        end
        -- Bottom
        local bottom = y + height - 1
        if bottom >= 1 and bottom <= buffer.height and col >= 1 and col <= buffer.width then
            buffer:setChar(col, bottom, char, color, colors.black)
        end
    end
    
    -- Left and right
    for dy = 1, height - 2 do
        local row = y + dy
        -- Left
        if row >= 1 and row <= buffer.height and x >= 1 and x <= buffer.width then
            buffer:setChar(x, row, char, color, colors.black)
        end
        -- Right
        local right = x + width - 1
        if row >= 1 and row <= buffer.height and right >= 1 and right <= buffer.width then
            buffer:setChar(right, row, char, color, colors.black)
        end
    end
end

-- Draw a line using Bresenham algorithm
function Shapes.drawLine(buffer, x1, y1, x2, y2, color, char)
    char = char or "-"
    
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = x1 < x2 and 1 or -1
    local sy = y1 < y2 and 1 or -1
    local err = dx - dy
    
    while true do
        if x1 >= 1 and x1 <= buffer.width and y1 >= 1 and y1 <= buffer.height then
            buffer:setChar(x1, y1, char, color, colors.black)
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

-- Draw a circle
function Shapes.drawCircle(buffer, centerX, centerY, radius, color)
    local x = radius
    local y = 0
    local err = 0
    
    while x >= y do
        buffer:setChar(centerX + x, centerY + y, "*", color, colors.black)
        buffer:setChar(centerX + y, centerY + x, "*", color, colors.black)
        buffer:setChar(centerX - y, centerY + x, "*", color, colors.black)
        buffer:setChar(centerX - x, centerY + y, "*", color, colors.black)
        buffer:setChar(centerX - x, centerY - y, "*", color, colors.black)
        buffer:setChar(centerX - y, centerY - x, "*", color, colors.black)
        buffer:setChar(centerX + y, centerY - x, "*", color, colors.black)
        buffer:setChar(centerX + x, centerY - y, "*", color, colors.black)
        
        if err <= 0 then
            y = y + 1
            err = err + 2 * y + 1
        else
            x = x - 1
            err = err - 2 * x + 1
        end
    end
end

return Shapes
