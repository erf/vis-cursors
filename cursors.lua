local module = {}
local cursors = {}
module.cursors_path = string.format('%s/.cursors', os.getenv('HOME'))

function set_cursor_pos(win)
	if win.file == nil or win.file.path == nil then return end
	local pos = cursors[win.file.path]
	if pos == nil then return end
	win.cursor.pos = tonumber(pos)
end

function init()
	cursors = {}
	local f = io.open(module.cursors_path)
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

function win_open(win)
	set_cursor_pos(win)
end

function win_close(win)
	if win.file == nil or win.file.path == nil then return end
	cursors[win.file.path] = win.cursor.pos
end

function quit()
	local f = io.open(module.cursors_path, 'w+')
	if f == nil then return end
	local a = {}
	for k in pairs(cursors) do table.insert(a, k) end
	table.sort(a)
	for i,k in ipairs(a) do 
		f:write(string.format('%s %d\n', k, cursors[k]))
	end
	f:close()
end

vis.events.subscribe(vis.events.INIT, init)
vis.events.subscribe(vis.events.WIN_OPEN, win_open)
vis.events.subscribe(vis.events.WIN_CLOSE, win_close)
vis.events.subscribe(vis.events.QUIT, quit)

return module
