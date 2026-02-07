-- Lightweight installer manifest loader and utilities
-- Used by the main installer to fetch and parse package information

local ManifestLoader = {}
ManifestLoader.__index = ManifestLoader

function ManifestLoader.new(baseUrl, manifestUrl)
    local self = setmetatable({}, ManifestLoader)
    self.baseUrl = baseUrl
    self.manifestUrl = manifestUrl
    self.manifest = nil
    return self
end

function ManifestLoader:fetch(url)
    local res = http.get(url)
    if not res then
        return nil, "HTTP GET failed"
    end
    local data = res.readAll()
    res.close()
    return data
end

function ManifestLoader:load()
    local data, err = self:fetch(self.manifestUrl)
    if not data then
        return false, "Failed to fetch manifest: " .. err
    end
    
    local ok, result = pcall(textutils.jsonDecode, data)
    if not ok then
        return false, "Failed to parse manifest JSON"
    end
    
    self.manifest = result
    return true
end

function ManifestLoader:getPackages()
    if not self.manifest then
        return nil, "Manifest not loaded"
    end
    return self.manifest.packages
end

function ManifestLoader:getPackageInfo(packageName)
    if not self.manifest or not self.manifest.packages then
        return nil
    end
    return self.manifest.packages[packageName]
end

function ManifestLoader:getPackageNames()
    local names = {}
    if self.manifest and self.manifest.packages then
        for name, _ in pairs(self.manifest.packages) do
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

function ManifestLoader:resolveDependencies(packageName, resolved)
    resolved = resolved or {}
    
    local pkg = self:getPackageInfo(packageName)
    if not pkg then
        return resolved
    end
    
    if resolved[packageName] then
        return resolved
    end
    
    -- Resolve dependencies first
    if pkg.dependencies then
        for _, dep in ipairs(pkg.dependencies) do
            self:resolveDependencies(dep, resolved)
        end
    end
    
    resolved[packageName] = pkg
    return resolved
end

return ManifestLoader
