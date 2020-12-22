local M = {}
local cursors = {}

local get_default_cache_path = function()
	local HOME = os.getenv('HOME')
	local XDG_CACHE_HOME = os.getenv('XDG_CACHE_HOME')
	local BASE = XDG_CACHE_HOME or HOME
	return BASE .. '/.vis-cursors.csv'
end

M.path = get_default_cache_path()

local apply_cursor_pos = function(win)
	if win.file == nil or win.file.path == nil then
		return
	end
	local pos = cursors[win.file.path]
	if pos == nil then
		return
	end
	win.selection.pos = tonumber(pos)
	vis:feedkeys("zz")
end

local file_exists = function(path)
	local f = io.open(path)
	if f == nil then
		return false
	end
	f:close()
	return true
end

local read_cursors = function()
	cursors = {}
	local f = io.open(M.path)
	if f == nil then
		return
	end
	-- read positions per file path
	for line in f:lines() do
		for path, pos in string.gmatch(line, '(.+)[,%s](%d+)') do
			cursors[path] = pos
		end
	end
	f:close()
end

local write_cursors = function()
	local f = io.open(M.path, 'w+')
	if f == nil then return end
	-- sort paths
	local paths = {}
	for path in pairs(cursors) do
		table.insert(paths, path)
	end
	table.sort(paths)
	-- buffer cursors string
	local t = {}
	for i, path in ipairs(paths) do
		table.insert(t, string.format('%s,%d', path, cursors[path]))
	end
	local s = table.concat(t, '\n')
	f:write(s)
	f:close()
end

local set_cursor_pos = function(win)
	if win.file == nil or win.file.path == nil then
		return
	end
	if not file_exists(win.file.path) then
		return
	end
	cursors[win.file.path] = win.selection.pos
end

vis.events.subscribe(vis.events.INIT, read_cursors)
vis.events.subscribe(vis.events.WIN_OPEN, apply_cursor_pos)
vis.events.subscribe(vis.events.WIN_CLOSE, set_cursor_pos)
vis.events.subscribe(vis.events.QUIT, write_cursors)

return M
