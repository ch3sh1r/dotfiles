local panel = require("modules/panel")

local rotator = string.format(
	"IIO_HYPRLAND_MODE=%s IIO_HYPRLAND_POSITION=%s IIO_HYPRLAND_SCALE=%s ~/.config/hypr/scripts/iio-hyprland-lua %s",
	panel.mode,
	panel.position,
	panel.scale,
	panel.output
)

local commands = {
	"qs",
	"wl-paste --watch cliphist store",
	rotator,
	"~/.local/bin/mullvad-network-profile",
	"~/.local/bin/sleep-lock",
}

hl.on("hyprland.start", function()
	for _, command in ipairs(commands) do
		hl.exec_cmd(command)
	end
end)
