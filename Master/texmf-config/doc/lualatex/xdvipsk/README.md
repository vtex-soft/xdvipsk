<!---
xdvipsk package bundle
Copyright 2026 Sigitas Tolušis

This work may be distributed and/or modified under the
conditions of the LaTeX Project Public License, either version 1.3
of this license or (at your option) any later version.
The latest version of this license is in
  http://www.latex-project.org/lppl.txt
and version 1.3 or later is part of all distributions of LaTeX
version 2005/12/01 or later.

This work has the LPPL maintenance status “maintained”.

The Current Maintainer of this work is Sigitas Tolušis.

This work consists of the files: xdvipsk.sty, luafontmaps.sty,
luafontmaps.lua, xdvipsk.def.
-->

# xdvipsk package bundle

`LaTeX` package bundle to support `xdvipsk` (extension of `dvips`) binary.

## info

`xdvipsk` binary info:
```
man xdvipsk
```

`xdvipsk` development sources:
```
https://github.com/vtex-soft/xdvipsk.git
```

## usage

```tex
\RequirePackage{xdvipsk}
\documentclass{...}
```

Option `noOpenType` disables OpenType font support.

## luaotfload configuration (luaotfload.conf)

Use this `luaotfload` configuration for proper use of `xdvipsk` with OpenType fonts:

```lua
[run]
  default-dvi-driver = xdvipsk
```

## --shell-escape

Enable creating a .xdvipsk catalog in the output directory.

## Notes

It’s the first steps. More information will be provided later.

-------------------
v1.0 2026-02-09 (ST)
