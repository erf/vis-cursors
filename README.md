# vis-cursors ✍️

A [vis](https://github.com/martanne/vis) [plugin](https://github.com/martanne/vis/wiki/Plugins) for saving cursor position per file.

Default save path is `{XDG_CACHE_HOME|HOME}/.vis-cursors`.

You can set a custom path with `M.path`.

Cursor positions are ordered by the last used file at the top of `.vis-cursors`.

You can limit the number of cursors/files by setting `maxsize` (which defaults to 1000).

