# vis-cursors ✍️

A [vis](https://github.com/martanne/vis) [plugin](https://github.com/martanne/vis/wiki/Plugins) for saving cursor position per file.

Default save path is `{XDG_CACHE_HOME|HOME/.cache}/vis-cursors.csv`.

Set a custom path with `M.path`.

Use `M.ignore` to set a list of patterns for paths to leave cursor at top left (defaults to `{ "COMMIT_EDITMSG$", "git%-rebase%-todo$" }` ).
