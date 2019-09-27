# Pandoc Tables Lua Filter

This filter converts YAML from `table` code blocks into tables.
See [example](example.md).

Usage (basic):

```sh
pandoc --lua-filter table.lua example.md -o example.html
```

Usage (with `pandoc-crossref`):

```sh
pandoc --standalone --lua-filter table.lua --filter pandoc-crossref example.md -o example.html
```

Features:

* Vertical and horizontal tables.
* Reusable templates for multiple tables of the same structure.

TODO:

* Automatic ID based on column title.
* Move to https://github.com/pandoc/lua-filters once filter is stable.

License: MIT
