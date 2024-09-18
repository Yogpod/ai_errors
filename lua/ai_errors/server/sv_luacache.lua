ai_errors.luacache = ai_errors.luacache or {}
ai_errors.luacache.paths = {}
ai_errors.luacache.files = {}

local paths, files = ai_errors.luacache.paths, ai_errors.luacache.files
local lower = string.lower
local gsub = string.gsub

function ai_errors.CleanPath(src)
	src = tostring(src)
	if paths[src] then return src, paths[src] end
	local original = src
	if src == "0" or src == "" then src = "_1_" end
	src = lower(src)
	src = gsub(src, "@", "")
	src = gsub(src, "^addons/[^/]+/lua/", "")
	src = gsub(src, "^addons/[^/]+/gamemodes/", "")
	src = gsub(src, "^addons/[^/]+/", "")
	src = gsub(src, "^lua/", "")
	src = gsub(src, "^gamemodes/", "")
	paths[original] = src
	return original, src
end

function ai_errors.ReadFile(path, cb)
	if files[path] then
		cb(files[path], FSASYNC_OK)
		return
	end
	local original, newPath = ai_errors.CleanPath(path)

	if not file.Exists(newPath, "LUA") then
		cb(false, FSASYNC_ERR_FAILURE)
		return
	end

	file.AsyncRead(newPath, "LUA", function(fileName, gamePath, status, data)
		if (status == FSASYNC_OK) then
			cb(data, status)
			files[original] = data
		else
			cb(false, status)
		end
	end)
end
