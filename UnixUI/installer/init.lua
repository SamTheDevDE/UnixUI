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
    
    -- Load UI
    local UI = {}
    
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
        print("║" .. UI.centerText(title, 38) .. "║")
        if subtitle then
            print("║" .. UI.centerText(subtitle, 38) .. "║")
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
            
            for i, opt in ipairs(options) do
                if i == selected then
                    UI.setColor(colors.black)
                    term.setBackgroundColor(colors.cyan)
                    print("▶ " .. opt.text)
                    UI.resetColor()
                    term.setBackgroundColor(colors.black)
                    if opt.desc then
                        print("  " .. opt.desc)
                    end
                else
                    UI.setColor(colors.white)
                    print("  " .. opt.text)
                    if opt.desc then
                        print("  " .. opt.desc)
                    end
                end
                print("")
            end
            
            UI.setColor(colors.gray)
            print("Use UP/DOWN arrows to select, ENTER to confirm")
            UI.resetColor()
            
            local event, key = os.pullEvent("key")
            
            if key == keys.up then
                selected = selected > 1 and selected - 1 or #options
            elseif key == keys.down then
                selected = selected < #options and selected + 1 or 1
            elseif key == keys.enter then
                return options[selected]
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
        
        while true do
            local event, key = os.pullEvent("key")
            if key == keys.enter then
                return true
            elseif key == keys.escape then
                return false
            end
        end
    end
    
    function UI.error(title, message)
        UI.clearScreen()
        UI.setColor(colors.red)
        print("!" .. string.rep("!", 38) .. "!")
        print("║" .. UI.centerText(title, 38) .. "║")
        print("!" .. string.rep("!", 38) .. "!")
        UI.resetColor()
        print("")
        print(message)
        print("")
        print("Press any key to exit...")
        os.pullEvent("key")
    end
    
    Installer.UI = UI
    
    -- Fetch from URL
    function Installer.fetch(url)
        local res = http.get(url)
        if not res then
            return nil, "HTTP GET failed"
        end
        local data = res.readAll()
        res.close()
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
    
    -- Load manifest
    function Installer.loadManifest()
        UI.header("UnixUI Installer", "Loading manifest...")
        print("Fetching manifest from server...")
        
        local manifestData, err = Installer.fetch(MANIFEST_URL)
        if not manifestData then
            UI.error("ERROR", "Could not fetch manifest!\n\n" .. err)
            return nil
        end
        
        local ok, result = pcall(textutils.jsonDecode, manifestData)
        if not ok then
            UI.error("ERROR", "Invalid manifest JSON!")
            return nil
        end
        
        UI.setColor(colors.lime)
        print("✓ Manifest loaded successfully")
        print("  Version: " .. (result.version or "unknown"))
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
        
        UI.header("Installing " .. pkg.name)
        print("")
        
        for i, filePath in ipairs(files) do
            local url = BASE_URL .. filePath
            local targetPath = filePath
            
            print("[" .. i .. "/" .. total .. "] " .. filePath)
            
            local data, err = Installer.fetch(url)
            if data then
                if Installer.writeFile(targetPath, data) then
                    UI.setColor(colors.lime)
                    print("  ✓ Success")
                    UI.resetColor()
                    success = success + 1
                else
                    UI.setColor(colors.red)
                    print("  ✗ Write failed")
                    UI.resetColor()
                    failed = failed + 1
                end
            else
                UI.setColor(colors.red)
                print("  ✗ " .. err)
                UI.resetColor()
                failed = failed + 1
            end
        end
        
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
        
        local manifest = Installer.loadManifest()
        if not manifest then
            return
        end
        
        -- Check if this is first-time installation (no .temp directory)
        local isFirstRun = not fs.exists(TEMP_DIR)
        
        if isFirstRun then
            -- Offer quick installation on first run
            UI.clearScreen()
            UI.setColor(colors.yellow)
            print("Welcome to UnixUI!")
            UI.resetColor()
            print("")
            print("This appears to be your first installation.")
            print("")
            print("You can:")
            print("1. Install Full (everything)")
            print("2. Install Core (rendering system only)")
            print("3. Choose packages manually")
            print("")
            
            local quickOptions = {
                {key = "full", text = "Full Installation", desc = "Everything"},
                {key = "core", text = "Core Only", desc = "Just rendering system"},
                {key = "manual", text = "Choose Packages", desc = "Custom selection"},
            }
            
            local selected = UI.menu("Quick Install", quickOptions)
            
            if not selected or selected.key == "manual" then
                -- Fall through to manual selection below
            else
                -- Auto-install the selected quick option
                Installer.installPackage(manifest, selected.key)
                print("")
                print("Press any key to exit...")
                os.pullEvent("key")
                return
            end
        end
        
        -- Create menu options for manual selection
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
    -- Try to load cached installer first
    local installer = loadCachedInstaller()
    
    if not installer then
        -- Create and run fresh installer
        installer = createInstaller()
    end
    
    installer.run()
end

main()
