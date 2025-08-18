# *xdvipsk*: extended dvips (TeXLive 2025)

It has a few base extensions:

* one allows flexible inclusion of bitmap images
* another extension solves a quite long-standing task -- adds OpenType font support
to `dvips` 
* accepts font map `\special` commands with prefixes `mapfile` and `mapline`
* extends with `Lua` callbacks for `specials`, `drawchar`, `drawrule` and `stack`
* `ToUnicode CMaps` support through adding `GlyphNames2Unicode` dictionary to `T1` and `OpenType` fonts
* accepts glyph names to unicode `\special` commands with prefixes `g2umapfile` and `g2umapline`
* accepts `GlyphNames2Unicode` dictionary directly from `<FONT_FILE_NAME>.g2u` file
* supports `dvi` OpenType font gid encoding with appropriate mapline and activated by
  `\special{vtex:settings.xdvipsk.opentype={enc=gid}}`

Source code repository at:

> <https://github.com/vtex-soft/xdvipsk.git>

Email bug reports, remarks, etc. to <tex-dev@vtex.lt>.

Developers and maintainers:

> Arūnas Povilaitis  
> Sigitas Tolušis  
> Mindaugas Piešina  

More info:

- [Overview](README.overview.md)
- [Usage](README.usage.md)
- [DeveloperNotes](README.developing.md)
- [Building](README.building.md)

It is successor and minimized version of:

> <https://github.com/vtex-soft/texlive.xdvipsk.git>

