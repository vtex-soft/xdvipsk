<!---
xdvipsk-support package bundle
Copyright 2026 Sigitas Tolušis

This work may be distributed and/or modified under the
conditions of the LaTeX Project Public License, either version 1.3c
of this license or (at your option) any later version.
The latest version of this license is in
  http://www.latex-project.org/lppl.txt
and version 1.3c or later is part of all distributions of LaTeX
version 2005/12/01 or later.

This work consists of the files: xdvipsk-suport.sty, xdvipskmaps.sty,
xdvipskmaps.lua, xdvipsk.def.
-->

# xdvipsk-support package bundle

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
\RequirePackage{xdvipsk-support}
\documentclass{...}
```

## options

- `noOpenType` -- disables OpenType font support;
- `otfchar` -- uses tex native charcodes for OpenType fonts
   (creates extra .xdvisk catalog, requires --shell-escape);
- `otfgid` -- uses gid encoding for OpenType fonts (supported by `LuaTeX` from Version 1.25.6).

Default option `otfgid` with fallback to `otfchar` for unsupported `LuaTeX` version.

## luaotfload configuration (luaotfload.conf)

Use this `luaotfload` configuration for proper use of `xdvipsk` with OpenType fonts:

```lua
[run]
  default-dvi-driver = xdvipsk
```

## --shell-escape

Enable creating a `.xdvipsk` catalog in the output directory.  
It’s used in OpenType font management with `otfchar` option.

## bitmap inclusion

The `xdvipsk` extension for bitmap images doesn’t require changes to the user-level syntax. 
The `\includegraphics` command should work as described in the `graphics` and `graphicx` package documentation.  

Declared `BMP`, `JPEG`, `PCX`, `PNG`, and `TIFF` image formats 
in the `xdvipsk.def` driver file as graphic inclusion rules.
```latex
    \@namedef{Gin@rule@.tif}#1{{bmp}{.tif.bb}{#1}}
    \@namedef{Gin@rule@.tiff}#1{{bmp}{.tiff.bb}{#1}}
    \@namedef{Gin@rule@.jpeg}#1{{bmp}{.jpeg.bb}{#1}}
    \@namedef{Gin@rule@.jpg}#1{{bmp}{.jpg.bb}{#1}}
    \@namedef{Gin@rule@.png}#1{{bmp}{.png.bb}{#1}}
```
Bitmaps can have various color models: `BW`, `gray`, `RGB`, `CMYK`, and `indexed RGB`.

Bitmap image file names are included in `DVI` files inside arguments of 
`\special` commands with prefix `em: graph` (originating from the EmTeX distribution).

## dvi specials: `mapfile` and `mapline`
```
    *mapfile* reads a font map file with one or more lines. The name of the map file 
    is given with an optional leading modifier character (+). The *mapline* special 
    scans single map lines. Its argument syntax matches map lines from a map file. 
    Both specials can be used concurrently. An optional modifier character (+) selects 
    the operation mode. It defines how individual map lines are handled and how 
    a collision between registered and newer entries is resolved. If a modifier is given, 
    a later entry is ignored with a warning. If no modifier is given, an existing entry 
    is replaced. Here are examples:
 
    \special{mapfile: +myfont.map}
    \special{mapline: +ptmri8r Times-Italic <8r.enc <ptmri8a.pfb}

     or 

    \special{mapfile: myfont.map}
    \special{mapline: ptmri8r Times-Italic <8r.enc <ptmri8a.pfb}
```

## Notes

It’s the first steps. More information will be provided later.

-------------------
v1.1 2026-04-10 (ST)
