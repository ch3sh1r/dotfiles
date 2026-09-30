local commands = {
	"qs",
	"wl-paste --watch cliphist store",
	"~/.local/bin/iio-hyprland-lua",
	"~/.local/bin/mullvad-network-profile",
	"~/.local/bin/sleep-lock",
}

hl.on("hyprland.start", function()
	for _, command in ipairs(commands) do
		hl.exec_cmd("uwsm app -s b -- " .. command)
	end
end)
