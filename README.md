# vis-cursors
Remembering cursor positions in the [vis editor](https://github.com/martanne/vis).

# How to 
1. `ln -s cursors.lua .config/vis/plugins`
2. `require('plugins/cursors')` in `visrc.lua`

`module.cursors_path` defaults to `~/.cursors`, and store your cursor positions. You can overwrite this variable.
