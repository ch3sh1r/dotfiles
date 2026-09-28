local mainMod = "SUPER"
local terminal = "alacritty"
local webBrowser = "brave"

local function bind_exec(keys, command, flags)
	hl.bind(keys, hl.dsp.exec_cmd(command), flags)
end

-- Reach the shell through a Hyprland global shortcut it registers
-- (GlobalShortcut { appid: "quickshell"; name: ... }), so a keypress spawns
-- nothing. `qs ipc call ...` remains available for scripts.
local function shell(name)
	return hl.dsp.global("quickshell:" .. name)
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
hl.bind(
	mainMod .. " + ALT + F",
	hl.dsp.window.fullscreen({
		mode = "maximized",
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

-- Shell overlays
local overlays = {
	{ key = "SPACE", name = "launcher" },
	{ key = "V", name = "clipboard" },
	{ key = "slash", name = "rbw" },
	{ key = "CTRL + I", name = "idle-toggle" },
}

for _, overlay in ipairs(overlays) do
	hl.bind(mainMod .. " + " .. overlay.key, shell(overlay.name))
end

-- Screenshot
bind_exec("Print", "hyprshot -m region -o ~/Pictures/Screenshots")
bind_exec(mainMod .. " + Print", "~/.local/bin/ocr-region")

-- Grouped windows
hl.bind(mainMod .. " + A", hl.dsp.group.toggle())
hl.bind(mainMod .. " + Z", hl.dsp.group.prev())
hl.bind(mainMod .. " + X", hl.dsp.group.next())

-- Lockscreen
hl.bind(mainMod .. " + CTRL + L", shell("lock"))
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

-- Volume and brightness keys are handled inside the shell (MediaKeys.qml),
-- which steps the level and shows the OSD without spawning a process.
local shell_keys = {
	{ key = "XF86AudioRaiseVolume", name = "volume-raise", repeating = true },
	{ key = "XF86AudioLowerVolume", name = "volume-lower", repeating = true },
	{ key = "ALT + XF86AudioRaiseVolume", name = "volume-raise-fine", repeating = true },
	{ key = "ALT + XF86AudioLowerVolume", name = "volume-lower-fine", repeating = true },
	{ key = "XF86AudioMute", name = "volume-mute" },
	{ key = "XF86AudioMicMute", name = "mic-mute" },
	{ key = "XF86MonBrightnessUp", name = "brightness-raise", repeating = true },
	{ key = "XF86MonBrightnessDown", name = "brightness-lower", repeating = true },
	{ key = "ALT + XF86MonBrightnessUp", name = "brightness-raise-fine", repeating = true },
	{ key = "ALT + XF86MonBrightnessDown", name = "brightness-lower-fine", repeating = true },
	{ key = "SHIFT + XF86MonBrightnessUp", name = "brightness-max" },
	{ key = "SHIFT + XF86MonBrightnessDown", name = "brightness-min" },
}

for _, shell_key in ipairs(shell_keys) do
	local flags = { locked = true }

	if shell_key.repeating then
		flags.repeating = true
	end

	hl.bind(shell_key.key, shell(shell_key.name), flags)
end

-- Media player keys
local media_keys = {
	{ key = "XF86AudioNext", command = "playerctl next" },
	{ key = "XF86AudioPause", command = "playerctl play-pause" },
	{ key = "XF86AudioPlay", command = "playerctl play-pause" },
	{ key = "XF86AudioPrev", command = "playerctl previous" },
}

for _, media_key in ipairs(media_keys) do
	bind_exec(media_key.key, media_key.command, { locked = true })
end
