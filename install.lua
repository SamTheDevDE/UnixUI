-- UnixUI Framework Installer Launcher
-- This file loads the actual installer from the installer package

-- Try to load the actual installer
local ok, err = pcall(function()
    dofile("UnixUI/installer/init.lua")
end)

if not ok then
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    print("ERROR")
    print("")
    print("An error occurred in the installer:")
    print(err)
    print("")
    print("Please delete the .temp folder and run the installer again")
    print("")
    print("If the problem persists, ensure:")
    print("- HTTP is enabled in ComputerCraft config")
    print("- You have internet access")
    print("- The installer files are present")
    term.setTextColor(colors.white)
end
