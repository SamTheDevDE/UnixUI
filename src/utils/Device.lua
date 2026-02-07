-- Device detection and initialization utilities
local Device = {}

-- Get monitor size
function Device.getMonSize()
    local mon = peripheral.find("monitor")
    if mon then
        return mon.getSize()
    end
    return nil
end

-- Get terminal size
function Device.getTermSize()
    return term.getSize()
end

-- Get output device (monitor or terminal)
function Device.getOutput()
    return peripheral.find("monitor") or term.current()
end

-- Check if a monitor is available
function Device.hasMonitor()
    return peripheral.find("monitor") ~= nil
end

return Device
