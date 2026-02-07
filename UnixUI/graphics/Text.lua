-- Text rendering utilities
local Text = {}

-- Write text at position
function Text.write(buffer, x, y, text, fgColor, bgColor)
    fgColor = fgColor or colors.white
    bgColor = bgColor or colors.black
    
    for i = 1, #text do
        local char = text:sub(i, i)
        buffer:setChar(x + i - 1, y, char, fgColor, bgColor)
    end
end

-- Print text at position
function Text.printAt(buffer, x, y, text, fgColor, bgColor)
    Text.write(buffer, x, y, text, fgColor, bgColor)
end

-- Print text centered horizontally
function Text.printCentered(buffer, y, text, fgColor, bgColor)
    local x = math.floor((buffer.width - #text) / 2) + 1
    Text.write(buffer, x, y, text, fgColor, bgColor)
end

-- Draw text in a box
function Text.printInBox(buffer, x, y, width, text, fgColor, bgColor)
    fgColor = fgColor or colors.white
    bgColor = bgColor or colors.black
    
    -- Fill background
    for i = 0, width - 1 do
        buffer:setChar(x + i, y, " ", fgColor, bgColor)
    end
    
    -- Write text (truncated if too long)
    local displayText = text:sub(1, width)
    Text.write(buffer, x, y, displayText, fgColor, bgColor)
end

-- Wrap text to width and return lines
function Text.wrapText(text, width)
    local lines = {}
    local currentLine = ""
    
    for word in text:gmatch("%S+") do
        if #currentLine + #word + 1 <= width then
            if currentLine == "" then
                currentLine = word
            else
                currentLine = currentLine .. " " .. word
            end
        else
            if currentLine ~= "" then
                table.insert(lines, currentLine)
            end
            currentLine = word
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    return lines
end

return Text
