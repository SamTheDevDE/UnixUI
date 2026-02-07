-- Main Renderer class combining all functionality
local Buffer = require("core.Buffer")
local Shapes = require("graphics.Shapes")
local Text = require("graphics.Text")
local Device = require("utils.Device")

local Renderer = {}
Renderer.__index = Renderer

-- Create a new renderer
function Renderer.new(output)
    local self = setmetatable({}, Renderer)
    
    self.output = output or Device.getOutput()
    self.width, self.height = self.output.getSize()
    self.buffer = Buffer.new(self.width, self.height)
    
    return self
end

-- Initialize with auto-detection
function Renderer.initialize()
    local output = Device.getOutput()
    return Renderer.new(output)
end

-- Get size
function Renderer:getSize()
    return self.width, self.height
end

-- Clear with color
function Renderer:clear(color)
    self.buffer:clear(color)
end

-- Set character
function Renderer:setChar(x, y, char, fgColor, bgColor)
    self.buffer:setChar(x, y, char, fgColor, bgColor)
end

-- ===== Text Methods =====
function Renderer:write(x, y, text, fgColor, bgColor)
    Text.write(self.buffer, x, y, text, fgColor, bgColor)
end

function Renderer:printAt(x, y, text, fgColor, bgColor)
    Text.printAt(self.buffer, x, y, text, fgColor, bgColor)
end

function Renderer:printCentered(y, text, fgColor, bgColor)
    Text.printCentered(self.buffer, y, text, fgColor, bgColor)
end

function Renderer:printInBox(x, y, width, text, fgColor, bgColor)
    Text.printInBox(self.buffer, x, y, width, text, fgColor, bgColor)
end

-- ===== Shape Methods =====
function Renderer:drawFilledRect(x, y, width, height, color)
    Shapes.drawFilledRect(self.buffer, x, y, width, height, color)
end

function Renderer:drawRect(x, y, width, height, color)
    Shapes.drawRect(self.buffer, x, y, width, height, color)
end

function Renderer:drawLine(x1, y1, x2, y2, color, char)
    Shapes.drawLine(self.buffer, x1, y1, x2, y2, color, char)
end

function Renderer:drawCircle(centerX, centerY, radius, color)
    Shapes.drawCircle(self.buffer, centerX, centerY, radius, color)
end

-- Render to screen
function Renderer:render()
    self.buffer:render(self.output)
end

return Renderer
