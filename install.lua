-- ComputerCraft/Tweaked installer: downloads files listed in manifest.json
-- Requirements: HTTP enabled in ComputerCraft: Tweaked config.

local BASE_URL = "https://github.samthedev.de/"
local MANIFEST_URL = BASE_URL .. "/manifest.json"
local TARGET_DIR = "/" -- change if you want a subfolder

local function log(msg)
  print(msg)
end

local function fetch(url)
  local res = http.get(url)
  if not res then
    error("HTTP GET failed: " .. url)
  end
  local data = res.readAll()
  res.close()
  return data
end

local function writeFile(path, data)
  local dir = fs.getDir(path)
  if dir and dir ~= "" then
    fs.makeDir(dir)
  end
  local h = assert(fs.open(path, "wb"))
  h.write(data)
  h.close()
end

local function install()
  log("Fetching manifest: " .. MANIFEST_URL)
  local manifestJson = fetch(MANIFEST_URL)
  local manifest = textutils.unserializeJSON(manifestJson)
  if not manifest or not manifest.files then
    error("Invalid manifest.json")
  end

  for _, item in ipairs(manifest.files) do
    local relPath = item.path
    local url = item.url or (BASE_URL .. "/files/" .. relPath)
    local targetPath = fs.combine(TARGET_DIR, relPath)
    log("Downloading " .. relPath .. " from " .. url)
    local data = fetch(url)
    writeFile(targetPath, data)
  end

  log("Install complete.")
end

pcall(install)