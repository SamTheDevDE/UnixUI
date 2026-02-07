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
    
    function UI.line(char, width)
        return string.rep(char or "-", width or 40)
    end
    
    function UI.progressBar(current, total, width)
        width = width or 30
        local filled = math.floor((current / total) * width)
        local empty = width - filled
        return "[" .. string.rep("=", filled) .. string.rep("-", empty) .. "] " .. current .. "/" .. total
    end
    
    function UI.header(title, subtitle)
        UI.clearScreen()
        UI.setColor(colors.blue)
        print("")
        print("  " .. UI.line("=", 36))
        print("  " .. UI.centerText(title, 36))
        if subtitle then
            print("  " .. UI.centerText(subtitle, 36))
        end
        print("  " .. UI.line("=", 36))
        UI.resetColor()
        print("")
    end
    
    function UI.menu(title, options)
        local selected = 1
        
        while true do
            UI.header(title)
            
            local optionLines = {}
            local lineNum = 7  -- First option starts after header (which ends at line 6)
            
            for i, opt in ipairs(options) do
                local isSelected = (i == selected)
                
                optionLines[lineNum] = i  -- Record which option is at this line
                
                if isSelected then
                    UI.setColor(colors.black)
                    term.setBackgroundColor(colors.cyan)
                    print("  > " .. opt.text)
                else
                    UI.setColor(colors.white)
                    print("    " .. opt.text)
                end
                
                lineNum = lineNum + 1
                
                if opt.desc then
                    term.setBackgroundColor(colors.black)
                    UI.setColor(colors.gray)
                    print("      " .. opt.desc)
                    UI.resetColor()
                    lineNum = lineNum + 1
                end
                
                print("")
                lineNum = lineNum + 1
            end
            
            UI.setColor(colors.gray)
            print("  UP/DOWN: Navigate | ENTER: Select | Click: Choose")
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
                    local button, x, y = event[2], event[3], event[4]
                    if optionLines[y] then
                        return options[optionLines[y]]
                    end
                elseif eventType == "monitor_touch" then
                    local side, x, y = event[2], event[3], event[4]
                    if side == UI.monitorSide and optionLines[y] then
                        return options[optionLines[y]]
                    end
                end
            end
        end
    end
    
    function UI.confirm(message)
        UI.clearScreen()
        print("")
        UI.setColor(colors.yellow)
        print("  " .. UI.centerText(message, 36))
        UI.resetColor()
        print("")
        print("  Press ENTER to continue")
        print("  Press ESC to cancel")
        print("")
        print("  [YES - CONTINUE]       [NO - CANCEL]")
        
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
                local button, x, y = event[2], event[3], event[4]
                if x <= 25 then
                    return true
                else
                    return false
                end
            elseif eventType == "monitor_touch" then
                local side, x, y = event[2], event[3], event[4]
                if side == UI.monitorSide then
                    if x <= 25 then
                        return true
                    else
                        return false
                    end
                end
            end
        end
    end
    
    function UI.installProgress(packageName, currentFile, totalFiles, fileName)
        UI.clearScreen()
        print("")
        UI.setColor(colors.lime)
        print("  Installing " .. packageName .. "...")
        UI.resetColor()
        print("")
        print("  " .. UI.progressBar(currentFile, totalFiles, 32))
        print("")
        UI.setColor(colors.gray)
        print("  File: " .. fileName)
        UI.resetColor()
    end
    
    function UI.installComplete(packageName, success, failed)
        UI.clearScreen()
        print("")
        UI.setColor(colors.cyan)
        print("  " .. UI.centerText("Installation Complete", 36))
        print("  " .. UI.line("-", 36))
        UI.resetColor()
        print("")
        print("  Package: " .. packageName)
        print("")
        UI.setColor(colors.lime)
        print("  [OK] " .. success .. " files installed")
        UI.resetColor()
        if failed > 0 then
            UI.setColor(colors.red)
            print("  [FAIL] " .. failed .. " files failed")
            UI.resetColor()
        end
        print("")
        print("  Press any key to continue...")
        os.pullEvent()
    end
    
    function UI.error(title, message)
        UI.clearScreen()
        print("")
        UI.setColor(colors.red)
        print("  " .. UI.line("!", 36))
        print("  " .. UI.centerText(title, 36))
        print("  " .. UI.line("!", 36))
        UI.resetColor()
        print("")
        print(message)
        print("")
        print("  Press any key or click to exit...")
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
        
        for i, filePath in ipairs(files) do
            -- Show progress screen with package name
            UI.usePrimary()
            UI.installProgress(pkg.name, i, total, filePath)
            
            local url = BASE_URL .. filePath
            local targetPath = filePath
            
            local data, err = Installer.fetch(url)
            if data then
                if Installer.writeFile(targetPath, data) then
                    success = success + 1
                else
                    failed = failed + 1
                end
            else
                failed = failed + 1
            end
            
            -- Update terminal status
            if UI.monitorDisplay then
                UI.useTerminal()
                term.clear()
                term.setCursorPos(1, 1)
                term.setTextColor(colors.yellow)
                print("Installing " .. pkg.name .. "...")
                print("")
                print("Progress: " .. i .. "/" .. total)
                term.setTextColor(colors.white)
                UI.usePrimary()
            end
        end
        
        -- Show completion screen
        UI.usePrimary()
        UI.installComplete(pkg.name, success, failed)
        
        -- Clear terminal
        if UI.monitorDisplay then
            UI.useTerminal()
            term.clear()
            term.setCursorPos(1, 1)
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
