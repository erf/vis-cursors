local M = {}
local cursors = {}
local files   = {}
M.maxcursors  = 0

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
	files   = {}
	local f = io.open(M.path)
	if f == nil then
		return
	end
	-- read positions per file path
	local n = 2 -- [n] is reserved to the current file
	for line in f:lines() do
		for path, pos in string.gmatch(line, '(.+)[,%s](%d+)') do
			cursors[path] = pos
			files[n] = path
			n = n+1
		end
	end
	f:close()
end

local write_cursors = function()
	local f = io.open(M.path, 'w+')
	if f == nil then return end
	for n=1,M.maxcursors do
		if files[n] then
			f:write(string.format('%s,%d\n', files[n], cursors[files[n]]))
		end
	end
	f:close()
end

local set_cursor_pos = function(win)
	read_cursors() -- reread M.path, which may be changed meanwhile by another vis instance
	if win.file == nil or win.file.path == nil then
		return
	end
	if not file_exists(win.file.path) then
		return
	end
	for key,val in pairs(files) do
		if val == win.file.path then
			files[key] = nil
			M.maxcursors = M.maxcursors+1
		end
	end
	files[1] = win.file.path
	cursors[win.file.path] = win.selection.pos
end

vis:option_register("maxcursors", "string", function(value, toggle)
	M.maxcursors = value
	return true
end, "The number of cursor positions to store")

vis.events.subscribe(vis.events.INIT, read_cursors)
vis.events.subscribe(vis.events.WIN_OPEN, apply_cursor_pos)
vis.events.subscribe(vis.events.WIN_CLOSE, set_cursor_pos)
vis.events.subscribe(vis.events.QUIT, write_cursors)

return M
