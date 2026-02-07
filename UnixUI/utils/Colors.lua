-- Color utilities
local Colors = {}

-- Convert color to hex string
function Colors.toHex(color)
    return string.format("%x", color)
end

-- Get a lighter version of a color (approximation)
function Colors.lighter(color)
    local lightMap = {
        [colors.black] = colors.gray,
        [colors.gray] = colors.lightGray,
        [colors.red] = colors.orange,
        [colors.orange] = colors.yellow,
        [colors.yellow] = colors.white,
        [colors.green] = colors.lime,
        [colors.blue] = colors.cyan,
        [colors.purple] = colors.magenta,
        [colors.white] = colors.white,
    }
    return lightMap[color] or color
end

-- Get a darker version of a color (approximation)
function Colors.darker(color)
    local darkMap = {
        [colors.white] = colors.lightGray,
        [colors.lightGray] = colors.gray,
        [colors.gray] = colors.black,
        [colors.yellow] = colors.orange,
        [colors.lime] = colors.green,
        [colors.cyan] = colors.blue,
        [colors.magenta] = colors.purple,
        [colors.orange] = colors.red,
        [colors.black] = colors.black,
    }
    return darkMap[color] or color
end

-- Color names
Colors.names = {
    black = colors.black,
    gray = colors.gray,
    lightGray = colors.lightGray,
    white = colors.white,
    red = colors.red,
    orange = colors.orange,
    yellow = colors.yellow,
    lime = colors.lime,
    green = colors.green,
    cyan = colors.cyan,
    blue = colors.blue,
    purple = colors.purple,
    magenta = colors.magenta,
    pink = colors.pink,
    brown = colors.brown,
}

return Colors
