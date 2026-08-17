local commands = {
	"qs",
	"wl-paste --watch cliphist store",
	"~/.config/hypr/scripts/iio-hyprland-lua DSI-1",
}

hl.on("hyprland.start", function()
	for _, command in ipairs(commands) do
		hl.exec_cmd(command)
	end
end)
