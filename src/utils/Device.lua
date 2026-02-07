-- Device detection and initialization utilities
local Device = {}

-- Find all monitors by checking peripherals
local function findMonitor()
    local mon = nil
    -- Try to find any monitor
    for _, side in ipairs(rs.getSides()) do
        if peripheral.getType(side) and peripheral.getType(side):match("monitor") then
            mon = peripheral.wrap(side)
            if mon then return mon end
        end
    end
    return nil
end

-- Get monitor size
function Device.getMonSize()
    local mon = findMonitor()
    if mon then
        return mon.getSize()
    end
    return nil
end

-- Get terminal size
function Device.getTermSize()
    return term.getSize()
end

-- Get output device (monitor or terminal) - prioritizes monitor
function Device.getOutput()
    local mon = findMonitor()
    if mon then
        return mon
    end
    return term.current()
end

-- Get all monitors
function Device.getAllMonitors()
    local monitors = {}
    for _, side in ipairs(rs.getSides()) do
        if peripheral.getType(side) and peripheral.getType(side):match("monitor") then
            table.insert(monitors, peripheral.wrap(side))
        end
    end
    return monitors
end

-- Check if a monitor is available
function Device.hasMonitor()
    return findMonitor() ~= nil
end

return Device
