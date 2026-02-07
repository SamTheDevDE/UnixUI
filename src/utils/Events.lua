-- Event handling utilities
local Events = {}

-- Event types
Events.types = {
    KEY = "key",
    KEY_UP = "key_up",
    MOUSE_CLICK = "mouse_click",
    MOUSE_DRAG = "mouse_drag",
    MOUSE_SCROLL = "mouse_scroll",
    TERM_RESIZE = "term_resize",
    CUSTOM = "custom",
}

-- Create an event handler
function Events.createHandler()
    local handler = {}
    handler.listeners = {}
    
    function handler:listen(eventType, callback)
        if not self.listeners[eventType] then
            self.listeners[eventType] = {}
        end
        table.insert(self.listeners[eventType], callback)
    end
    
    function handler:unlisten(eventType, callback)
        if self.listeners[eventType] then
            for i, listener in ipairs(self.listeners[eventType]) do
                if listener == callback then
                    table.remove(self.listeners[eventType], i)
                    break
                end
            end
        end
    end
    
    function handler:emit(eventType, ...)
        if self.listeners[eventType] then
            for _, listener in ipairs(self.listeners[eventType]) do
                listener(...)
            end
        end
    end
    
    function handler:processEvent(eventName, ...)
        self:emit(eventName, ...)
    end
    
    return handler
end

-- Wait for a specific event
function Events.waitFor(eventType, timeout)
    timeout = timeout or math.huge
    local startTime = os.clock()
    
    while true do
        local event, a, b, c, d, e = os.pullEvent(eventType)
        if os.clock() - startTime > timeout then
            return nil, "timeout"
        end
        return event, a, b, c, d, e
    end
end

-- Wait for any event from a list
function Events.waitForAny(eventTypes, timeout)
    timeout = timeout or math.huge
    local startTime = os.clock()
    
    while true do
        if os.clock() - startTime > timeout then
            return nil, "timeout"
        end
        
        local event, a, b, c, d, e = os.pullEventRaw()
        for _, eventType in ipairs(eventTypes) do
            if event == eventType then
                return event, a, b, c, d, e
            end
        end
    end
end

return Events
