-- UnixUI Framework initialization
-- Exports all main modules for easy access

local UnixUI = {}

-- Core modules
UnixUI.Renderer = require("core.Renderer")
UnixUI.Buffer = require("core.Buffer")

-- Graphics modules
UnixUI.Shapes = require("graphics.Shapes")
UnixUI.Text = require("graphics.Text")

-- Utility modules
UnixUI.Device = require("utils.Device")
UnixUI.Colors = require("utils.Colors")
UnixUI.Events = require("utils.Events")
UnixUI.Input = require("utils.Input")
UnixUI.Layout = require("utils.Layout")

-- Component modules
UnixUI.Button = require("components.Button")
UnixUI.Panel = require("components.Panel")

-- Version and info
UnixUI.version = "0.2.0"
UnixUI.name = "UnixUI"

-- Quick start helper
function UnixUI.newRenderer()
    return UnixUI.Renderer.initialize()
end

-- Get color utilities
function UnixUI.getColors()
    return UnixUI.Colors
end

-- Get layout utilities
function UnixUI.getLayout()
    return UnixUI.Layout
end

return UnixUI
