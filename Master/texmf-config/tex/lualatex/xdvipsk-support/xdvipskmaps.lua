--
--  This is file `xdvipskmaps.lua',
--
--  Copyright (C) 2026 by Sigitas Tolusis <sigitas@vtex.lt>
--
--  This work is under the LPPL Version 1.3c license.
--

module('xdvipskmaps', package.seeall)

xdvipskmaps.module = {
    name          = "xdvipskmaps",
    version       =  1.1,
    date          = "2026/04/10",
    description   = "Lua tex support package.",
    author        = "Sigitas Tolusis",
    copyright     = "Sigitas Tolusis",
    license       = "LPPL Version 1.3c",
}

luatexbase.provides_module(xdvipskmaps.module)

local sformat = string.format

config = config or { }
config.lualibs = config.lualibs or { }
config.lualibs.load_extended = false

require "lualibs"

config.xdvipskmaps = {}

local vtx_fonts_info = vtx_fonts_info or { }
vtx_fonts_info.otf_fonts = vtx_fonts_info.otf_fonts or { }
vtx_fonts_info.tfm_fonts = vtx_fonts_info.tfm_fonts or { }
vtx_fonts_info.encodings = vtx_fonts_info.encodings or { }

local dvifont_driver = fonts.constructors.features.otf.defaults.dvifont

local dvifont_driver_info = "The `luaotfload` package is loaded with dvifont driver" ..
dvifont_driver .. ". " ..
[[Use another `luaotfload` configuration to use `xdvipsk` with OpenType fonts:

luaotfload.conf
---------------
[run]
  default-dvi-driver = xdvipsk
---------------

Trying to change driver on fly. No guarantee to be okay!
]]

function check_dvifont_driver()
   if dvifont_driver ~= 'xdvipsk' then
      luatexbase.module_warning('xdvipskmaps', dvifont_driver_info)
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
   local options = config.xdvipskmaps
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
      if fd == nil then
         luatexbase.module_error('xdvipskmaps', "Enable —shell-escape to create a catalog in the output directory.!")
      end
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
   end
end

dvi_output = function(p, f)
   -- "dd->R", p, f, &result
   local result = nil
   if (p == 1) then
      result = format_mapline(f)
   end
   return result
end

format_mapline = function(f)
   local mapline = nil
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
      mapline = 'mapline: ' .. tfmname .. ' ' .. ' ' .. psname .. ' "' .. fontname .. '" >' .. filename .. subfont
   else
      -- type1 font
   end
   return mapline
end

--
-- End of file `xdvipskmaps.lua'.
