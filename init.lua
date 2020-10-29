local M = {}
local cursors = {}
local XDG_CACHE_HOME = os.getenv('XDG_CACHE_HOME')
if XDG_CACHE_HOME then 
	M.path =  XDG_CACHE_HOME .. '/cursors'
else
	M.path = os.getenv('HOME') .. '/.cursors'
end

function apply_cursor_pos(win)
	if win.file == nil or win.file.path == nil then return end
	local pos = cursors[win.file.path]
	if pos == nil then return end
	win.selection.pos = tonumber(pos)
	vis:feedkeys("zz")
end

function file_exists(path)
	local f = io.open(path)
	if f == nil then return false
	else f:close() return true 
	end
end	

function read_cursors()
	cursors = {}
	local f = io.open(M.path)
	if f == nil then return end
	-- read positions per file path
	for line in f:lines() do
		for path, pos in string.gmatch(line, '(.+)%s(%d+)') do
			cursors[path] = pos
		end 
	end
	f:close()
end

function write_cursors()
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
		table.insert(t, string.format('%s %d', path, cursors[path]))
	end
	local s = table.concat(t, '\n')
	f:write(s)
	f:close()
end

function set_cursor_pos(win)
	if win.file == nil or win.file.path == nil then return end
	if not file_exists(win.file.path) then return end
	cursors[win.file.path] = win.selection.pos
end

vis.events.subscribe(vis.events.INIT, read_cursors)
vis.events.subscribe(vis.events.WIN_OPEN, apply_cursor_pos)
vis.events.subscribe(vis.events.WIN_CLOSE, set_cursor_pos)
vis.events.subscribe(vis.events.QUIT, write_cursors)

return M
