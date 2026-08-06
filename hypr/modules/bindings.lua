local mainMod = "SUPER"
local terminal = "alacritty"
local webBrowser = "brave"

local function bind(keys, dispatcher, flags)
	hl.bind(keys, dispatcher, flags)
end

local function bind_exec(keys, command, flags)
	bind(keys, hl.dsp.exec_cmd(command), flags)
end

-- Common apps
bind_exec(mainMod .. " + Return", terminal)
bind(mainMod .. " + C", hl.dsp.window.close())
bind(
	mainMod .. " + F",
	hl.dsp.window.fullscreen({
		mode = "fullscreen",
		action = "toggle",
	})
)

local apps = {
	{ key = "E", command = "nautilus" },
	{ key = "W", command = webBrowser },
	{ key = "SHIFT + W", command = webBrowser .. " --incognito" },
	{ key = "CTRL + W", command = webBrowser .. ' --app="$(wl-paste --no-newline)"' },
	{ key = "SHIFT + P", command = webBrowser .. " --app=https://www.perplexity.ai/" },
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
bind(mainMod .. " + A", hl.dsp.group.toggle())
bind(mainMod .. " + Z", hl.dsp.group.prev())
bind(mainMod .. " + X", hl.dsp.group.next())

-- Lockscreen
bind_exec(mainMod .. " + CTRL + L", "hyprlock")
bind_exec("switch:Lid Switch", "hyprlock", { locked = true })

local directions = {
	{ key = "H", direction = "l" },
	{ key = "L", direction = "r" },
	{ key = "K", direction = "u" },
	{ key = "J", direction = "d" },
}

for _, item in ipairs(directions) do
	bind(mainMod .. " + " .. item.key, hl.dsp.focus({ direction = item.direction }))
	bind(mainMod .. " + SHIFT + " .. item.key, hl.dsp.window.move({ direction = item.direction }))
end

-- Move workspace between monitors
bind(mainMod .. " + CTRL + J", hl.dsp.workspace.move({ monitor = "+1" }))
bind(mainMod .. " + CTRL + K", hl.dsp.workspace.move({ monitor = "-1" }))

-- Switch workspaces
for i = 1, 9 do
	bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Scroll through existing workspaces
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
local media_keys = {
	{ key = "XF86AudioRaiseVolume", command = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", repeating = true },
	{ key = "XF86AudioLowerVolume", command = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", repeating = true },
	{ key = "XF86AudioMute", command = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", repeating = true },
	{ key = "XF86AudioMicMute", command = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", repeating = true },
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
