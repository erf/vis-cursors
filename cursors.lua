local module = {}
local cursors = {}
module.path = string.format('%s/.cursors', os.getenv('HOME'))

function set_cursor_pos(win)
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

function load_cursors()
	cursors = {}
	local f = io.open(module.path)
	if f == nil then return end
	for line in f:lines() do
		for k, v in string.gmatch(line, '(.+)%s(%d+)') do
			cursors[k] = v
		end 
	end
	f:close()
	for win in vis:windows() do
		set_cursor_pos(win)
	end
end

function save_cursors()
	local f = io.open(module.path, 'w+')
	if f == nil then return end
	local a = {}
	for k in pairs(cursors) do table.insert(a, k) end
	table.sort(a)
	for i,k in ipairs(a) do 
		f:write(string.format('%s %d\n', k, cursors[k]))
	end
	f:close()
end

function win_close(win)
	if win.file == nil or win.file.path == nil then return end
	if not file_exists(win.file.path) then return end
	cursors[win.file.path] = win.selection.pos
end

vis.events.subscribe(vis.events.INIT, load_cursors)
vis.events.subscribe(vis.events.WIN_OPEN, set_cursor_pos)
vis.events.subscribe(vis.events.WIN_CLOSE, win_close)
vis.events.subscribe(vis.events.QUIT, save_cursors)

return module
