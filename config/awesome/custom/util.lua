------------------------------------------------
-- Lua utility definitions (custom.lua)
-- by intelfx
--   intelfx100 at gmail dot com
------------------------------------------------
local wibox = require("wibox")

-- Theme functions

function colorize (fg, bg, font)
	local span_attrs = ""
	if fg then span_attrs = span_attrs .. " foreground=\"" .. fg .. "\"" end
	if bg then span_attrs = span_attrs .. " background=\"" .. bg .. "\"" end
	if font then span_attrs = span_attrs .. " font=\"" .. font .. "\"" end

	return function (text) return "<span" .. span_attrs .. ">" .. text .. "</span>" end
end

function widget_text (fg_text, fg_icon, bg, font)
	return function (icon, text)
		local result = colorize (fg_text, bg) (text)
		if icon then
			result = colorize (fg_icon, bg, font) (icon) .. " " .. result
		end
		return result
	end
end


-- Action helper function

function exec_and_update (cmd, widgets)
	return string.format ("/bin/bash -c \"%s; echo 'vicious.force ({ %s })' | awesome-client\"", cmd, widgets)
end

function exec_and_update_term (cmd, widgets)
	return terminal .. " -e " .. exec_and_update (cmd, widgets)
end

function exec_and_update_term_hold (cmd, widgets)
	return terminal .. " -hold -e " .. exec_and_update (cmd, widgets)
end


-- Misc functions

function string:split (sep)
	local fields = {}

	self:gsub (string.format ("([^%s]+)", sep), function (word) table.insert (fields, word) end)
	return fields
end

function hashtable (array)
	local ht = {}

	for i, value in pairs (array) do
		ht[tonumber (value)] = true

	end
	return ht
end

function to_utf8(unicode_list)
	local result = ''
	local w,x,y,z = 0,0,0,0
	local function modulo(a, b)
		return a - math.floor(a/b) * b
	end
	
	for i,v in ipairs(unicode_list) do
		if v ~= 0 and v ~= nil then
			if v <= 0x7F then -- same as ASCII
				result = result .. string.char(v)
			elseif v >= 0x80 and v <= 0x7FF then -- 2 bytes
				y = math.floor(modulo(v, 0x000800) / 64)
				z = modulo(v, 0x000040)
				result = result .. string.char(0xC0 + y, 0x80 + z)
			elseif (v >= 0x800 and v <= 0xD7FF) or (v >= 0xE000 and v <= 0xFFFF) then -- 3 bytes
				x = math.floor(modulo(v, 0x010000) / 4096)
				y = math.floor(modulo(v, 0x001000) / 64)
				z = modulo(v, 0x000040)
				result = result .. string.char(0xE0 + x, 0x80 + y, 0x80 + z)
			elseif (v >= 0x10000 and v <= 0x10FFFF) then -- 4 bytes
				w = math.floor(modulo(v, 0x200000) / 262144)
				x = math.floor(modulo(v, 0x040000) / 4096)
				y = math.floor(modulo(v, 0x001000) / 64)
				z = modulo(v, 0x000040)
				result = result .. string.char(0xF0 + w, 0x80 + x, 0x80 + y, 0x80 + z)
			end
		end
	end
	return result
end

function private_char (ord)
	return to_utf8 ({0xea00 + ord})
end


-- Widget helper functions

function textbox (text)
	local w = wibox.widget.textbox()
	if text then w:set_markup (text) end
	return w
end

function progressbar()
	local bar = awful.widget.progressbar ()
	bar:set_width (50)
	bar:set_height (1)
	bar:set_vertical (false)
	bar:set_background_color (beautiful.bar_bg)
	bar:set_color (beautiful.bar_fg)
	bar:set_border_color (nil)
	return bar
end

function vicious_box (...)
	local w = textbox()
	vicious.register (w, ...)
	return w
end


-- Widget group functions

function build_bar (bar)
	return wibox.layout.margin ( bar, 0, 0, 7, 7 )
end

function build_fixed (...)
	local b_pack = wibox.layout.fixed.horizontal ()

	local pack = {...}
	for i,v in ipairs (pack) do
		b_pack:add (v)
	end

	return b_pack
end

function build_group (opener, closer)
	local w_opener = textbox (opener)
	local w_closer = textbox (closer)
	local space = textbox (" ")

	return function (icon, ...)
		local b_pack = wibox.layout.fixed.horizontal ()

		b_pack:add (w_opener)
		b_pack:add (icon)

		local pack = {...}
		for i,v in ipairs (pack) do
			b_pack:add (space)
			b_pack:add (v)
		end

		b_pack:add (w_closer)
		return b_pack
	end
end

function build_bracketed (...)
	return build_group ("[ ", " ]") (...)
end

function build_bracketed_space (...)
	return build_group (" [ ", " ] ") (...)
end


-- Data extraction functions

function read_file (path)
	local file = io.open (path, "rb")
	return file and file:read ("*all") or nil
end

function cpu_list (path)
	local ranges = read_file (path)
	local result = {}

	if not ranges then return result end

	for i, subrange in ipairs (ranges:split (",")) do
		local bounds = subrange:split ("-")

		if #bounds == 1 then
			table.insert (result, subrange)
		elseif #bounds == 2 then
			for cpu = bounds[1], bounds[2] do
				table.insert (result, cpu)
			end
		else
			error ("cpu list parse failure: string '" .. ranges .. "', subrange '" .. subrange .. "'")
		end
	end

	return result
end
