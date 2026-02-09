--
--  This is file `luafontmaps.lua',
--
--  Copyright (C) 2026 by Sigitas Tolusis <sigitas@vtex.lt>
--
--  This work is under the CC0 license.
--

module('luafontmaps', package.seeall)

luafontmaps.module = {
    name          = "luafontmaps",
    version       =  1.0,
    date          = "2026/02/09",
    description   = "Lua tex support package.",
    author        = "Sigitas Tolusis",
    copyright     = "Sigitas Tolusis",
    license       = "CC0",
}

luatexbase.provides_module(luafontmaps.module)

local sformat = string.format

config = config or { }
config.lualibs = config.lualibs or { }
config.lualibs.load_extended = false

require "lualibs"

config.luafontmaps = {}
config.luafontmaps.debug = false

local vtx_fonts_info = vtx_fonts_info or { }
vtx_fonts_info.otf_fonts = vtx_fonts_info.otf_fonts or { }
vtx_fonts_info.tfm_fonts = vtx_fonts_info.tfm_fonts or { }
vtx_fonts_info.encodings = vtx_fonts_info.encodings or { }

local dvifont_driver = fonts.constructors.features.otf.defaults.dvifont

local dvifont_driver_info = "The `luaotfload` package is loaded with dvifont driver" ..
dvifont_driver .. ". " ..
[[To use `xdvipsk` with OpenType fonts, use another `luaotfload` configuration:

luaotfload.conf
---------------
[run]
  default-dvi-driver = xdvipsk
---------------

Trying to change driver on fly. No guarantee to be okay!
]]

function check_dvifont_driver()
   if dvifont_driver ~= 'xdvipsk' then
      luatexbase.module_warning('luafontmaps', dvifont_driver_info)
      fonts.constructors.features.otf.defaults.dvifont = 'xdvipsk'
      if luatexbase.in_callback('pre_shipout_filter', 'luaotfload.dvi') then
         luatexbase.remove_from_callback('pre_shipout_filter', 'luaotfload.dvi')
      end
   end
end

function get_utf16(val)
   local uni = val
   if (type(val) == 'number') then
      if val <= 0x10FFFF then
         if val >=  0x10000 then
            uni = sformat('%04X', 0xD800 | ((val >> 10) & 0x3FF))
               .. sformat('%04X', 0xDC00 | (val & 0x3FF))
         else
            uni = sformat('%04X', val)
         end
      else
         uni = sformat('%04X', (0x0000FFFD >> 8) & 0xFF)
            .. sformat('%04X', (0x0000FFFD & 0xFF))
      end
   end
   return uni
end

function createfontsmap()
   local options = config.luafontmaps
   local selfautoparent = kpse.expand_var('$SELFAUTOPARENT')
   local selfautograndparent = kpse.expand_var('$SELFAUTOGRANDPARENT')
   for i,v in table.sortedhash(fonts.hashes.identifiers) do
      local tfmname = v.name:gsub( "%s$", "")
      if v['format'] ~= 'unknown' then
         local filename = v.filename:gsub("^harfloaded:", "")
         filename = filename:gsub("^" .. selfautoparent, "$SELFAUTOPARENT"):gsub("^" .. selfautograndparent, "$SELFAUTOGRANDPARENT"):gsub( "%s$", "")
         local fontname = v.fullname:gsub('[<>:"/\\|%?%*]', '@')
         local psname = v.psname:gsub( "%s$", "")
         local subfont = v.shared and v.shared.rawdata and v.shared.rawdata.subfont
         if vtx_fonts_info.otf_fonts[tfmname] == nil then 
            vtx_fonts_info.otf_fonts[tfmname] = tfmname .. '\t' .. '\t' .. psname .. '\t' .. fontname .. '\t>' .. filename
            if subfont then
               vtx_fonts_info.otf_fonts[tfmname] = vtx_fonts_info.otf_fonts[tfmname] .. "(" .. tostring(subfont) .. ")"
            end
         end
         if vtx_fonts_info.encodings[fontname] == nil then
            vtx_fonts_info.encodings[fontname] = { }
            local temp_table_var = vtx_fonts_info.encodings[fontname]
            for key,value in table.sortedhash(v["characters"]) do
               local uni = get_utf16(value.tounicode)
               temp_table_var[#temp_table_var+1] = sformat("%s,%s,%s,%s,%s", key, value.index, uni, value.width, value.height)
            end
            vtx_fonts_info.encodings[fontname] = temp_table_var
         end
      else
         if vtx_fonts_info.tfm_fonts[tfmname] == nil then
             vtx_fonts_info.tfm_fonts[tfmname] = v["properties"]
         end
      end
   end
   if next(vtx_fonts_info.otf_fonts, nil) ~= nil then 
      local output_dir = options.output_dir or ".xdvipsk"
      if not lfs.isdir(output_dir) then
         lfs.mkdir(output_dir)
      end
      local fd = io.open(output_dir .. "/" .. tex.jobname .. '.opentype.map', 'w')
      for key,value in table.sortedhash(vtx_fonts_info.otf_fonts) do
         fd:write(value .. "\n")
      end
      fd:close()
      for key,value in table.sortedhash(vtx_fonts_info.encodings) do
         local fd = io.open(sformat("%s/%s.encodings.map", output_dir, key), 'w')
         for _,item in ipairs(value) do
             fd:write(item .. "\n")
         end
         fd:close()
      end
   end
end

function buildpage_filter_callback(extrainfo)
   if extrainfo == "end" then
      if fonts then
         createfontsmap()
      end
      if luafontmaps.fd then
         luafontmaps.fd:close()
      end
   end
end

font_definition = function(f, n)
   -- "d->N", f, &font_definition
   local mapline, mapline_old = format_mapline(f)
   if mapline ~= nil then
      n = node.new(node.id('whatsit'), node.subtype("special"))
      n.data = "mapline: " .. mapline
      --
      if luafontmaps.extra_maps then
         local tfmname = fonts.hashes.identifiers[f]
         if vtx_fonts_info.otf_fonts[tfmname] == nil then
            vtx_fonts_info.otf_fonts[tfmname] = mapline_old
         end
      end
      --
   end
   return n
end

format_mapline = function(f)
   local mapline = nil
   local mapline_old = nil
   local selfautoparent = kpse.expand_var('$SELFAUTOPARENT')
   local selfautograndparent = kpse.expand_var('$SELFAUTOGRANDPARENT')
   local v = fonts.hashes.identifiers[f]
   local tfmname = v.name:gsub( "%s$", "")
   if v['format'] ~= 'unknown' then
      local filename = v.filename:gsub("^harfloaded:", "")
      filename = filename:gsub("^" .. selfautoparent, "$SELFAUTOPARENT"):gsub("^" .. selfautograndparent, "$SELFAUTOGRANDPARENT"):gsub( "%s$", "")
      local fontname = v.fullname:gsub('[<>:"/\\|%?%*]', '@')
      local psname = v.psname:gsub( "%s$", "")
      local subfont = v.shared and v.shared.rawdata and v.shared.rawdata.subfont
      subfont = ((subfont and "(" .. tostring(subfont) .. ")") or "")
      mapline = tfmname .. ' ' .. ' ' .. psname .. ' "' .. fontname .. '" >' .. filename .. subfont
      --
      if luafontmaps.extra_maps then
         mapline_old = tfmname .. '\t' .. '\t' .. psname .. '\t' .. fontname .. '\t>' .. filename .. subfont
      end
      --
   else
      -- type1 font
   end
   return mapline, mapline_old
end

place_glyph = function(parent_box, f, font_encoding, c, gid, uni, dvi_pointer, h, v)
   -- "dddddSddd->NN", parent_box, f, font_encoding, c, char_index(f, c), uni, dvi_pointer, dvi.h, dvi.v
   local fnt = fonts.hashes.identifiers[f]
   if font_encoding == 2 then
      if luafontmaps.place_glyphs then
         luafontmaps.fd:write(table.concat({tex.count[0], fnt.name, gid, (uni or ''), h, v, dvi_pointer}, ',')..'\n')
      end
      if luafontmaps.extra_maps then
         local fontname = fnt.fullname:gsub('[<>:"/\\|%?%*]', '@')
         vtx_fonts_info.encodings[fontname] = vtx_fonts_info.encodings[fontname] or { }
         if vtx_fonts_info.encodings[fontname][c] == nil then
            local value = fnt["characters"][c]
            vtx_fonts_info.encodings[fontname][c] = sformat("%s,%s,%s,%s,%s", c, gid, get_utf16(uni), value.width, value.height)
         end
      end
   else
      if luafontmaps.place_glyphs then
         luafontmaps.fd:write(table.concat({tex.count[0], fnt.name, c, (uni or ''), h, v, dvi_pointer},',')..'\n')
      end
   end
   return nil,nil
end

function place_glyph_end(extrainfo)
   if extrainfo == "end" then
      if luafontmaps.fd then
         luafontmaps.fd:close()
      end
      if luafontmaps.extra_maps and next(vtx_fonts_info.otf_fonts, nil) then
         local output_dir = config.luafontmaps.output_dir or ".xdvipsk"
         if not lfs.isdir(output_dir) then
            lfs.mkdir(output_dir)
         end
         local fd = io.open(output_dir .. "/" .. tex.jobname .. '.opentype.map', 'w')
         for key,value in table.sortedhash(vtx_fonts_info.otf_fonts) do
            fd:write(value .. "\n")
         end
         fd:close()
         for key,value in table.sortedhash(vtx_fonts_info.encodings) do
            local fd = io.open(sformat("%s/%s.encodings.map", output_dir, key), 'w')
            for k,v in table.sortedhash(value) do
               fd:write(v .. "\n")
            end
            fd:close()
         end
      end
   end
end

--
-- End of file `luafontmaps.lua'.
