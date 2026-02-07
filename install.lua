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
        
        -- Verify we got valid Lua code (should start with comment or local/function)
        if not code or #code == 0 then
            term.clear()
            term.setCursorPos(1, 1)
            term.setTextColor(colors.red)
            print("ERROR: Downloaded empty file")
            term.setTextColor(colors.white)
            return
        end
        
        if code:find("<!DOCTYPE") or code:find("<html") then
            term.clear()
            term.setCursorPos(1, 1)
            term.setTextColor(colors.red)
            print("ERROR: Downloaded HTML instead of Lua")
            print("The custom domain may not be set up yet")
            print("")
            print("Try installing from dev branch:")
            print("wget https://samthedevde.github.io/UnixUI/install.lua install.lua")
            term.setTextColor(colors.white)
            return
        end
        
        -- Execute the installer code with proper environment
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
    print("- Check custom domain: unixui.samthedev.de")
    term.setTextColor(colors.white)
end
