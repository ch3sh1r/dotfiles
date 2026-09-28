-- Built-in display, shared by monitors.lua and the iio rotation script.
return {
	output = "DSI-1",
	mode = "1200x1920@60.0",
	position = "4760x3046",
	scale = 1.5,
	-- Upright orientation; iio-hyprland-lua maps "normal" to the same value.
	transform = 3,
}
