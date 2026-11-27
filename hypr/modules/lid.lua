local panel = require("modules/panel")
local M = {}
local timer, rotation, inputs_enabled
local sleep_requested = false
local panel_inputs = {
	"gxtp7380:00-27c6:0113",
	"gxtp7380:00-27c6:0113-stylus",
}

local function set_panel_input(enabled)
	if inputs_enabled == enabled then
		return
	end
	for _, name in ipairs(panel_inputs) do
		hl.device({ name = name, enabled = enabled, output = panel.output })
	end
	inputs_enabled = enabled
end

-- Hyprland 0.56.2 crashes when creating timers in --verify-config mode.
local cmdline = io.open("/proc/self/cmdline", "r")
local verifying = false
if cmdline then
	verifying = cmdline:read("*a"):find("%z%-%-verify%-config%z") ~= nil
	cmdline:close()
end

local function lid_closed()
	local file = io.open("/proc/acpi/button/lid/LID0/state", "r")
	if not file then
		return nil
	end
	local state = file:read("*a"):match("state:%s*(%a+)")
	file:close()
	if state == "closed" or state == "open" then
		return state == "closed"
	end
end

local function externally_powered()
	local file = io.open("/sys/class/power_supply/ADP1/online", "r")
	if not file then
		return false
	end
	local online = file:read("*a"):match("^%s*1%s*$") ~= nil
	file:close()
	return online
end

local function panel_spec()
	local spec = {}
	for key, value in pairs(panel) do
		spec[key] = value
	end
	spec.disabled = false
	spec.transform = rotation or panel.transform
	return spec
end

local function apply_rotation(spec)
	hl.monitor(spec)
	hl.config({ input = {
		touchdevice = { output = spec.output, transform = spec.transform },
		tablet = { output = spec.output, transform = spec.transform },
	} })
end

-- Cache rotation without enabling a closed or disabled panel.
function M.rotate(spec)
	if spec.output == panel.output then
		rotation = spec.transform
		if lid_closed() ~= false then
			return
		end
	end
	if hl.get_monitor(spec.output) then
		apply_rotation(spec)
		hl.exec_scheduled_prop_refresh_immediately()
	end
end

function M.reconcile()
	local closed = lid_closed()
	if closed == nil then
		return
	end
	local internal = hl.get_monitor(panel.output)
	rotation = rotation or (internal and internal.transform) or panel.transform
	set_panel_input(not closed)
	if not closed then
		sleep_requested = false
		if not internal or internal.transform ~= rotation then
			apply_rotation(panel_spec())
		end
		return
	end

	local external
	for _, monitor in ipairs(hl.get_monitors()) do
		if monitor.name ~= panel.output then
			external = true
			break
		end
	end
	if external then
		sleep_requested = false
		if internal then
			local active = internal.active_workspace
			-- Moving an empty workspace can destroy its weak Lua handle.
			local show_workspace = active and ((active.windows or 0) > 0 or internal.focused)
				and tostring(active.id) or nil
			-- Removing an output evacuates its workspaces in Hyprland itself.
			hl.monitor({ output = panel.output, disabled = true })
			hl.exec_scheduled_prop_refresh_immediately()
			if show_workspace then
				hl.dispatch(hl.dsp.focus({ workspace = show_workspace }))
			end
		end
	elseif externally_powered() then
		sleep_requested = false
	elseif not sleep_requested then
		if not internal then
			apply_rotation(panel_spec())
		end
		sleep_requested = true
		-- Existing sleep-lock secures the session before sleep.
		hl.exec_cmd("systemctl suspend")
	end
end

local function schedule(delay)
	if verifying then
		return
	end
	if timer then
		timer:set_enabled(false)
	end
	timer = hl.timer(function()
		timer = nil
		M.reconcile()
		hl.exec_scheduled_prop_refresh_immediately()
	end, { timeout = delay, type = "oneshot" })
end

local lid_bind_flags = { locked = true, dont_inhibit = true, submap_universal = true }
hl.bind("switch:on:Lid Switch", function() schedule(200) end, lid_bind_flags)
hl.bind("switch:off:Lid Switch", function() schedule(200) end, lid_bind_flags)
for _, event in ipairs({ "hyprland.start", "config.reloaded", "monitor.layout_changed" }) do
	hl.on(event, function() schedule(2000) end)
end

return M
