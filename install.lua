-- UnixUI Framework Installer Launcher
-- Downloads and runs the installer

local BASE_URL = "https://unixui.samthedev.de/"
local INSTALLER_URL = BASE_URL .. "installer/init.lua"

-- Check if running locally (UnixUI folder exists) or remotely (downloaded via wget)
local function runInstaller()
    if fs.exists("UnixUI/installer/init.lua") then
        -- Running locally - load from file
        dofile("UnixUI/installer/init.lua")
    else
        -- Running remotely - download from URL
        if not http then
            term.clear()
            term.setCursorPos(1, 1)
            term.setTextColor(colors.red)
            print("ERROR: HTTP API not available")
            term.setTextColor(colors.white)
            return
        end
        
        local res = http.get(INSTALLER_URL)
        if not res then
            term.clear()
            term.setCursorPos(1, 1)
            term.setTextColor(colors.red)
            print("ERROR: Failed to download installer")
            print("URL: " .. INSTALLER_URL)
            term.setTextColor(colors.white)
            return
        end
        
        local code = res.readAll()
        res.close()
        
        -- Execute the installer code
        local fn, err = load(code, "installer")
        if not fn then
            term.clear()
            term.setCursorPos(1, 1)
            term.setTextColor(colors.red)
            print("ERROR: Failed to parse installer")
            print(err)
            term.setTextColor(colors.white)
            return
        end
        
        fn()
    end
end

local ok, err = pcall(runInstaller)

if not ok then
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    print("ERROR")
    print("")
    print("An error occurred:")
    print(err)
    print("")
    print("Troubleshooting:")
    print("- Ensure HTTP is enabled")
    print("- Check your internet connection")
    print("- Try deleting .temp folder")
    term.setTextColor(colors.white)
end
