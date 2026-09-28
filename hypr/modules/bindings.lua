local mainMod = "SUPER"
local terminal = "alacritty"
local webBrowser = "brave"

local function bind_exec(keys, command, flags)
	hl.bind(keys, hl.dsp.exec_cmd(command), flags)
end

-- Windows and session
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(
	mainMod .. " + F",
	hl.dsp.window.fullscreen({
		mode = "fullscreen",
		action = "toggle",
	})
)
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())

-- Common apps
local apps = {
	{ key = "Return", command = terminal },
	{ key = "E", command = "nautilus" },
	{ key = "W", command = webBrowser },
	{ key = "SHIFT + W", command = webBrowser .. " --incognito" },
	{ key = "CTRL + W", command = webBrowser .. ' --app="$(wl-paste --no-newline)"' },
	{ key = "SHIFT + G", command = webBrowser .. " --app=https://chatgpt.com/" },
	{ key = "SHIFT + S", command = webBrowser .. " --app=https://open.spotify.com/" },
	{ key = "SHIFT + T", command = webBrowser .. " --app=https://teams.cloud.microsoft/" },
	{ key = "O", command = "obsidian" },
	{ key = "T", command = "Telegram" },
	{ key = "B", command = "blueman-manager" },
	{ key = "CTRL + B", command = "~/.local/BurpSuitePro/BurpSuitePro" },
}

for _, app in ipairs(apps) do
	bind_exec(mainMod .. " + " .. app.key, app.command)
end

-- Menus
local menus = {
	{ key = "SPACE", command = "qs ipc call launcher toggle" },
	{ key = "V", command = "qs ipc call selector clipboard" },
	{ key = "slash", command = "qs ipc call selector rbw menu" },
}

for _, menu in ipairs(menus) do
	bind_exec(mainMod .. " + " .. menu.key, menu.command)
end

-- Screenshot
bind_exec("Print", "hyprshot -m region -o ~/Pictures/Screenshots")
bind_exec(mainMod .. " + Print", "~/.local/bin/ocr-region")

-- Grouped windows
hl.bind(mainMod .. " + A", hl.dsp.group.toggle())
hl.bind(mainMod .. " + Z", hl.dsp.group.prev())
hl.bind(mainMod .. " + X", hl.dsp.group.next())

-- Lockscreen
bind_exec(mainMod .. " + CTRL + L", "qs ipc call lock lock")
bind_exec("switch:on:Lid Switch", "qs ipc call lock lock", { locked = true })

local directions = {
	{ key = "H", direction = "l" },
	{ key = "L", direction = "r" },
	{ key = "K", direction = "u" },
	{ key = "J", direction = "d" },
}

for _, item in ipairs(directions) do
	hl.bind(mainMod .. " + " .. item.key, hl.dsp.focus({ direction = item.direction }))
	hl.bind(mainMod .. " + SHIFT + " .. item.key, hl.dsp.window.move({ direction = item.direction }))
end

-- Move workspace between monitors
hl.bind(mainMod .. " + CTRL + J", hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.workspace.move({ monitor = "-1" }))

-- Switch workspaces
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Scroll through workspaces on the current monitor (same as the swipe gesture)
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "m-1" }))

-- Move/resize windows
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
local media_keys = {
	{ key = "XF86AudioRaiseVolume", command = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", repeating = true },
	{ key = "XF86AudioLowerVolume", command = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", repeating = true },
	{ key = "XF86AudioMute", command = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
	{ key = "XF86AudioMicMute", command = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
	{ key = "XF86MonBrightnessUp", command = "brightnessctl s 10%+", repeating = true },
	{ key = "XF86MonBrightnessDown", command = "brightnessctl s 10%-", repeating = true },
	{ key = "XF86AudioNext", command = "playerctl next" },
	{ key = "XF86AudioPause", command = "playerctl play-pause" },
	{ key = "XF86AudioPlay", command = "playerctl play-pause" },
	{ key = "XF86AudioPrev", command = "playerctl previous" },
}

for _, media_key in ipairs(media_keys) do
	local flags = { locked = true }

	if media_key.repeating then
		flags.repeating = true
	end

	bind_exec(media_key.key, media_key.command, flags)
end
