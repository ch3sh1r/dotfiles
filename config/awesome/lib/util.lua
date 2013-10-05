------------------------------------------------
-- Lua utility definitions (custom.lua)
-- by intelfx
--   intelfx100 at gmail dot com
------------------------------------------------
local wibox = require("wibox")

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
	return build_group ('<span color="#F0DFAF">[</span> ', ' <span color="#F0DFAF">]</span>') (...)
end
