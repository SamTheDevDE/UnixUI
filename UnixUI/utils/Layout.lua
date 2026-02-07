-- Layout and positioning utilities
local Layout = {}

-- Alignment constants
Layout.align = {
    LEFT = "left",
    CENTER = "center",
    RIGHT = "right",
    TOP = "top",
    MIDDLE = "middle",
    BOTTOM = "bottom",
}

-- Calculate centered position
function Layout.center(itemSize, containerSize)
    return math.floor((containerSize - itemSize) / 2) + 1
end

-- Calculate right-aligned position
function Layout.right(itemSize, containerSize)
    return containerSize - itemSize + 1
end

-- Create a grid layout
function Layout.createGridLayout(x, y, cols, rows, cellWidth, cellHeight, spacing)
    spacing = spacing or 0
    local layout = {}
    layout.cells = {}
    
    for row = 1, rows do
        layout.cells[row] = {}
        for col = 1, cols do
            local cellX = x + (col - 1) * (cellWidth + spacing)
            local cellY = y + (row - 1) * (cellHeight + spacing)
            layout.cells[row][col] = {
                x = cellX,
                y = cellY,
                width = cellWidth,
                height = cellHeight,
            }
        end
    end
    
    function layout:getCell(row, col)
        if row >= 1 and row <= rows and col >= 1 and col <= cols then
            return self.cells[row][col]
        end
        return nil
    end
    
    return layout
end

-- Create an anchored layout
function Layout.createAnchoredLayout(x, y, width, height)
    local layout = {}
    layout.x = x
    layout.y = y
    layout.width = width
    layout.height = height
    layout.elements = {}
    
    function layout:add(element, anchor)
        anchor = anchor or "top-left"
        local element_info = {
            element = element,
            anchor = anchor,
        }
        
        if anchor == "top-left" then
            element.x = x
            element.y = y
        elseif anchor == "top-center" then
            element.x = x + math.floor((width - element.width) / 2)
            element.y = y
        elseif anchor == "top-right" then
            element.x = x + width - element.width
            element.y = y
        elseif anchor == "center" then
            element.x = x + math.floor((width - element.width) / 2)
            element.y = y + math.floor((height - element.height) / 2)
        end
        
        table.insert(self.elements, element_info)
    end
    
    return layout
end

-- Calculate padding
function Layout.getPadding(padding)
    if type(padding) == "number" then
        return padding, padding, padding, padding
    elseif type(padding) == "table" then
        return padding[1] or 0, padding[2] or 0, padding[3] or 0, padding[4] or 0
    end
    return 0, 0, 0, 0
end

-- Get available space after padding
function Layout.getAvailableSpace(x, y, width, height, padding)
    local top, right, bottom, left = Layout.getPadding(padding)
    return x + left, y + top, width - left - right, height - top - bottom
end

return Layout
