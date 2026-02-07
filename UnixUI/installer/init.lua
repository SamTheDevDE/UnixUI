-- UnixUI Framework Installer
-- Main installer entry point with smart loading

local BASE_URL = "https://unixui.samthedev.de/"
local MANIFEST_URL = "https://unixui.samthedev.de/manifest.json"
local TEMP_DIR = ".temp"
local INSTALLER_CACHE = TEMP_DIR .. "/installer"
local BASE_PATH = "UnixUI/"

-- Try to load cached installer first
local function loadCachedInstaller()
    if fs.exists(INSTALLER_CACHE) then
        local ok, installer = pcall(function()
            return dofile(INSTALLER_CACHE)
        end)
        
        if ok and installer then
            return installer
        end
    end
    return nil
end

-- Create lightweight installer
local function createInstaller()
    local Installer = {}
    Installer.baseUrl = BASE_URL
    Installer.manifestUrl = MANIFEST_URL
    Installer.tempDir = TEMP_DIR
    
    -- Detect and setup display
    local currentDisplay = term.current()
    local monitorSide = nil
    local terminalDisplay = term.current()
    local monitorDisplay = nil
    
    -- Try to find a monitor
    for _, side in ipairs({"top", "bottom", "left", "right", "front", "back"}) do
        if peripheral.isPresent(side) and peripheral.getType(side) == "monitor" then
            monitorSide = side
            monitorDisplay = peripheral.wrap(side)
            currentDisplay = monitorDisplay
            break
        end
    end
    
    -- Redirect to monitor if found
    if monitorSide then
        term.redirect(currentDisplay)
    end
    
    -- Load UI
    local UI = {}
    UI.currentDisplay = currentDisplay
    UI.monitorSide = monitorSide
    UI.terminalDisplay = terminalDisplay
    UI.monitorDisplay = monitorDisplay
    
    -- Switch between displays
    function UI.useMonitor()
        if UI.monitorDisplay then
            term.redirect(UI.monitorDisplay)
        end
    end
    
    function UI.useTerminal()
        term.redirect(UI.terminalDisplay)
    end
    
    function UI.usePrimary()
        term.redirect(UI.currentDisplay)
    end
    
    function UI.clearScreen()
        term.clear()
        term.setCursorPos(1, 1)
    end
    
    function UI.setColor(color)
        term.setTextColor(color)
    end
    
    function UI.resetColor()
        term.setTextColor(colors.white)
    end
    
    function UI.centerText(text, width)
        width = width or 40
        local padding = math.floor((width - #text) / 2)
        return string.rep(" ", padding) .. text .. string.rep(" ", width - padding - #text)
    end
    
    function UI.header(title, subtitle)
        UI.clearScreen()
        UI.setColor(colors.blue)
        print("=" .. string.rep("=", 38) .. "=")
        print("|" .. UI.centerText(title, 38) .. "|")
        if subtitle then
            print("|" .. UI.centerText(subtitle, 38) .. "|")
        end
        print("=" .. string.rep("=", 38) .. "=")
        UI.resetColor()
        print("")
    end
    
    function UI.menu(title, options)
        local selected = 1
        
        while true do
            UI.header(title)
            print("")
            
            local optionLines = {} -- Track which lines have clickable options
            local lineNum = 5 -- Start after header
            
            for i, opt in ipairs(options) do
                if i == selected then
                    UI.setColor(colors.black)
                    term.setBackgroundColor(colors.cyan)
                    print("> " .. opt.text)
                    optionLines[lineNum] = i
                    UI.resetColor()
                    term.setBackgroundColor(colors.black)
                    lineNum = lineNum + 1
                    if opt.desc then
                        print("  " .. opt.desc)
                        lineNum = lineNum + 1
                    end
                else
                    UI.setColor(colors.white)
                    print("  " .. opt.text)
                    optionLines[lineNum] = i
                    lineNum = lineNum + 1
                    if opt.desc then
                        print("  " .. opt.desc)
                        lineNum = lineNum + 1
                    end
                end
                print("")
                lineNum = lineNum + 1
            end
            
            UI.setColor(colors.gray)
            print("Use UP/DOWN arrows to select, ENTER to confirm, or click")
            UI.resetColor()
            
            while true do
                local event = {os.pullEvent()}
                local eventType = event[1]
                
                if eventType == "key" then
                    local key = event[2]
                    if key == keys.up then
                        selected = selected > 1 and selected - 1 or #options
                        break
                    elseif key == keys.down then
                        selected = selected < #options and selected + 1 or 1
                        break
                    elseif key == keys.enter then
                        return options[selected]
                    end
                elseif eventType == "mouse_click" then
                    -- Terminal click
                    local button, x, y = event[2], event[3], event[4]
                    if optionLines[y] then
                        selected = optionLines[y]
                        return options[selected]
                    end
                elseif eventType == "monitor_touch" then
                    -- Monitor click
                    local side, x, y = event[2], event[3], event[4]
                    if side == UI.monitorSide and optionLines[y] then
                        selected = optionLines[y]
                        return options[selected]
                    end
                end
            end
        end
    end
    
    function UI.confirm(message)
        UI.clearScreen()
        UI.setColor(colors.yellow)
        print(message)
        UI.resetColor()
        print("")
        print("Press ENTER to continue or ESC to cancel")
        print("(or click YES/NO)")
        print("")
        print("[YES - CONTINUE]  [NO - CANCEL]")
        
        while true do
            local event = {os.pullEvent()}
            local eventType = event[1]
            
            if eventType == "key" then
                local key = event[2]
                if key == keys.enter then
                    return true
                elseif key == keys.escape then
                    return false
                end
            elseif eventType == "mouse_click" then
                -- Terminal click
                local button, x, y = event[2], event[3], event[4]
                if x <= 20 then
                    return true
                elseif x > 20 then
                    return false
                end
            elseif eventType == "monitor_touch" then
                -- Monitor click
                local side, x, y = event[2], event[3], event[4]
                if side == UI.monitorSide then
                    if x <= 20 then
                        return true
                    elseif x > 20 then
                        return false
                    end
                end
            end
        end
    end
    
    function UI.error(title, message)
        UI.clearScreen()
        UI.setColor(colors.red)
        print("!" .. string.rep("!", 38) .. "!")
        print("|" .. UI.centerText(title, 38) .. "|")
        print("!" .. string.rep("!", 38) .. "!")
        UI.resetColor()
        print("")
        print(message)
        print("")
        print("Press any key or click to exit...")
        os.pullEvent()
    end
    
    Installer.UI = UI
    
    -- Fetch from URL
    function Installer.fetch(url)
        if not http then
            return nil, "HTTP API not available"
        end
        
        local res = http.get(url)
        if not res then
            return nil, "HTTP request failed for: " .. url
        end
        
        local data = res.readAll()
        res.close()
        
        if not data or #data == 0 then
            return nil, "Empty response from server"
        end
        
        return data
    end
    
    -- Write file
    function Installer.writeFile(path, data)
        local dir = fs.getDir(path)
        if dir and dir ~= "" then
            fs.makeDir(dir)
        end
        local h = fs.open(path, "w")
        if not h then
            return false
        end
        h.write(data)
        h.close()
        return true
    end
    
    -- Simple JSON parse (for manifest only)
    local function parseJSON(json)
        local pos = 1
        local function skip()
            while pos <= #json and json:sub(pos, pos):match("[%s\n\r\t]") do
                pos = pos + 1
            end
        end
        local function parseValue()
            skip()
            local ch = json:sub(pos, pos)
            if ch == "{" then
                pos = pos + 1
                local t = {}
                skip()
                if json:sub(pos, pos) ~= "}" then
                    while true do
                        skip()
                        -- Parse key
                        if json:sub(pos, pos) ~= '"' then return nil end
                        pos = pos + 1
                        local keyStart = pos
                        while pos <= #json and json:sub(pos, pos) ~= '"' do pos = pos + 1 end
                        local key = json:sub(keyStart, pos - 1)
                        pos = pos + 1
                        skip()
                        if json:sub(pos, pos) ~= ":" then return nil end
                        pos = pos + 1
                        local val = parseValue()
                        if not val then return nil end
                        t[key] = val
                        skip()
                        local ch = json:sub(pos, pos)
                        if ch == "}" then break end
                        if ch ~= "," then return nil end
                        pos = pos + 1
                    end
                end
                pos = pos + 1
                return t
            elseif ch == "[" then
                pos = pos + 1
                local t = {}
                skip()
                if json:sub(pos, pos) ~= "]" then
                    while true do
                        local val = parseValue()
                        if not val then return nil end
                        table.insert(t, val)
                        skip()
                        local ch = json:sub(pos, pos)
                        if ch == "]" then break end
                        if ch ~= "," then return nil end
                        pos = pos + 1
                    end
                end
                pos = pos + 1
                return t
            elseif ch == '"' then
                pos = pos + 1
                local start = pos
                while pos <= #json and json:sub(pos, pos) ~= '"' do pos = pos + 1 end
                local str = json:sub(start, pos - 1)
                pos = pos + 1
                return str
            elseif json:sub(pos, pos + 3) == "true" then
                pos = pos + 4
                return true
            elseif json:sub(pos, pos + 4) == "false" then
                pos = pos + 5
                return false
            elseif json:sub(pos, pos + 3) == "null" then
                pos = pos + 4
                return nil
            else
                local start = pos
                while pos <= #json and json:sub(pos, pos):match("[%d%.%-+eE]") do pos = pos + 1 end
                local numStr = json:sub(start, pos - 1)
                return tonumber(numStr)
            end
        end
        return parseValue()
    end
    
    -- Load manifest
    function Installer.loadManifest()
        UI.header("UnixUI Installer", "Loading manifest...")
        print("Fetching manifest from server...")
        print("URL: " .. MANIFEST_URL)
        print("")
        
        local manifestData, err = Installer.fetch(MANIFEST_URL)
        if not manifestData then
            UI.error("ERROR", "Could not fetch manifest!\n\n" .. (err or "Unknown error"))
            return nil
        end
        
        print("[OK] Downloaded " .. #manifestData .. " bytes")
        
        local ok, result = pcall(parseJSON, manifestData)
        if not ok or not result then
            print("[FAIL] Failed to parse manifest")
            print("Error: " .. tostring(result))
            print("")
            sleep(2)
            UI.error("ERROR", "Invalid manifest format!")
            return nil
        end
        
        if not result.packages or type(result.packages) ~= "table" then
            UI.error("ERROR", "Manifest missing 'packages' field!")
            return nil
        end
        
        UI.setColor(colors.lime)
        print("[OK] Manifest loaded successfully")
        print("  Version: " .. (result.version or "unknown"))
        print("  Packages: " .. (result.packages and "yes" or "no"))
        UI.resetColor()
        sleep(1)
        
        return result
    end
    
    -- Install files from manifest
    function Installer.installPackage(manifest, packageName)
        if not manifest.packages or not manifest.packages[packageName] then
            UI.error("ERROR", "Package not found: " .. packageName)
            return false
        end
        
        local pkg = manifest.packages[packageName]
        local files = pkg.files or {}
        local total = #files
        local success = 0
        local failed = 0
        
        -- Show installation on monitor
        UI.usePrimary()
        UI.header("Installing " .. pkg.name)
        print("")
        
        -- If we have a monitor, show status on terminal too
        if UI.monitorDisplay then
            UI.useTerminal()
            term.clear()
            term.setCursorPos(1, 1)
            term.setTextColor(colors.yellow)
            print("Installation in progress...")
            print("Check monitor for details")
            term.setTextColor(colors.white)
            UI.usePrimary()
        end
        
        for i, filePath in ipairs(files) do
            local url = BASE_URL .. filePath
            local targetPath = filePath
            
            UI.usePrimary()
            print("[" .. i .. "/" .. total .. "] " .. filePath)
            
            local data, err = Installer.fetch(url)
            if data then
                if Installer.writeFile(targetPath, data) then
                    UI.setColor(colors.lime)
                    print("  [OK] Success")
                    UI.resetColor()
                    success = success + 1
                else
                    UI.setColor(colors.red)
                    print("  [FAIL] Write failed")
                    UI.resetColor()
                    failed = failed + 1
                end
            else
                UI.setColor(colors.red)
                print("  [FAIL] " .. err)
                UI.resetColor()
                failed = failed + 1
            end
            
            -- Update terminal status
            if UI.monitorDisplay then
                UI.useTerminal()
                term.setCursorPos(1, 3)
                term.clearLine()
                print("Progress: " .. i .. "/" .. total .. " files")
                UI.usePrimary()
            end
        end
        
        UI.usePrimary()
        print("")
        print("Installation Summary:")
        UI.setColor(colors.lime)
        print("Success: " .. success)
        UI.resetColor()
        if failed > 0 then
            UI.setColor(colors.red)
            print("Failed:  " .. failed)
            UI.resetColor()
        end
        
        -- Clear terminal status
        if UI.monitorDisplay then
            UI.useTerminal()
            term.clear()
            term.setCursorPos(1, 1)
            term.setTextColor(colors.lime)
            print("Installation complete!")
            print("Check monitor for details")
            term.setTextColor(colors.white)
            UI.usePrimary()
        end
        
        return failed == 0
    end
    
    -- Get package names
    function Installer.getPackageNames(manifest)
        local names = {}
        if manifest.packages then
            for name, _ in pairs(manifest.packages) do
                table.insert(names, name)
            end
        end
        table.sort(names)
        return names
    end
    
    -- Main flow
    function Installer.run()
        if not http then
            UI.error("ERROR", "HTTP API not available!\n\nPlease enable HTTP in your ComputerCraft config")
            return
        end
        
        -- Show display info
        if UI.monitorDisplay then
            UI.usePrimary()
            UI.header("UnixUI Installer", "Multi-Display Mode")
            print("Monitor detected on: " .. UI.monitorSide)
            print("Using monitor for main display")
            print("Terminal will show status updates")
            print("")
            sleep(2)
        end
        
        local manifest = Installer.loadManifest()
        if not manifest then
            return
        end
        
        -- Check if this is first-time installation (no .temp directory existed before)
        -- We create .temp in main(), so just check if the marker file exists
        local isFirstRun = not fs.exists(TEMP_DIR .. "/installed")
        
        if isFirstRun then
            -- Auto-install installer package on first run
            UI.header("UnixUI Installer", "First run detected")
            print("Installing installer package...")
            print("This will cache the installer locally")
            print("")
            
            -- Mark as installed
            local marker = fs.open(TEMP_DIR .. "/installed", "w")
            if marker then
                marker.write("true")
                marker.close()
            end
            
            Installer.installPackage(manifest, "installer")
            
            print("")
            print("Installer cached successfully!")
            print("Run the installer again to install packages")
            print("")
            print("Press any key to exit...")
            os.pullEvent()
            return
        end
        
        -- Create menu options for returning users
        local packageNames = Installer.getPackageNames(manifest)
        local options = {}
        
        for _, name in ipairs(packageNames) do
            local pkg = manifest.packages[name]
            table.insert(options, {
                key = name,
                text = pkg.name,
                desc = pkg.description,
            })
        end
        
        table.insert(options, {
            key = "exit",
            text = "Exit",
            desc = "Cancel installation",
        })
        
        local selected = UI.menu("UnixUI Installer", options)
        
        if not selected or selected.key == "exit" then
            return
        end
        
        local pkg = manifest.packages[selected.key]
        if not UI.confirm("Install " .. pkg.name .. "?\n\n(" .. #pkg.files .. " files)") then
            return
        end
        
        Installer.installPackage(manifest, selected.key)
        
        print("")
        print("Press any key to exit...")
        os.pullEvent("key")
    end
    
    return Installer
end

-- Main entry point
local function main()
    -- Store original terminal
    local originalTerm = term.current()
    
    -- Ensure .temp directory exists
    if not fs.exists(TEMP_DIR) then
        fs.makeDir(TEMP_DIR)
    end
    
    -- Try to load cached installer first
    local installer = loadCachedInstaller()
    
    if not installer then
        -- Create and run fresh installer
        installer = createInstaller()
    end
    
    installer.run()
    
    -- Restore terminal
    term.redirect(originalTerm)
    term.clear()
    term.setCursorPos(1, 1)
end

main()
