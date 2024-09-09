ai_errors.luacache = ai_errors.luacache or {}
ai_errors.luacache.paths = {}
ai_errors.luacache.files = {}

local paths, files = ai_errors.luacache.paths, ai_errors.luacache.files

function ai_errors.CleanPath(src)
	src = tostring(src)
	if paths[src] then return src, paths[src] end
	local original = src
	if src == "0" or src == "" then src = "_1_" end
	src = src:lower()
	src = src:gsub("@", "")
	src = src:gsub("^addons/[^/]+/lua/", "")
	src = src:gsub("^addons/[^/]+/gamemodes/", "")
	src = src:gsub("^addons/[^/]+/", "")
	src = src:gsub("^lua/", "")
	src = src:gsub("^gamemodes/", "")
	paths[original] = src
	return original, src
end

function ai_errors.ReadFile(path, cb)
	if files[path] then
		cb(files[path])
		return
	end

	if not file.Exists(path, "LUA") then
		cb(false)
		return
	end

	local original, newPath = ai_errors.CleanPath(path)
	file.AsyncRead(newPath, "LUA", function(fileName, gamePath, status, data)
		if (status == FSASYNC_OK) then
			cb(data)
			files[original] = data
		else
			cb(false)
		end
	end)
end
