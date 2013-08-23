local wibox = require("wibox")

battery_widget = wibox.widget.textbox()
battery_widget:set_align("right")

function update_battery(widget)
    local fd=io.popen("acpitool -b", "r")
    local line=fd:read()
    fd:close()
    local battery_load_num = tonumber(string.match(line, " (%d*\.%d+)%%"))
    local battery_load = string.format("%.d", battery_load_num)
    local time_rem = string.match(line, "(%d+\:%d+)\:%d+")

    local battery = "⚡ " .. battery_load .. "%"
    if time_rem then
        if string.match(line, "Discharging") == "Discharging" then
            battery = battery .. " ↓ "
        else
            battery = battery .. " ↑ "
        end
        battery = battery .. time_rem
    end
    if battery_load_num < 20 then
        battery = '<span color="#ff4d00">' .. battery .. '</span>'
    end
    widget:set_markup(battery)
end

update_battery(battery_widget)
battery_widget_timer=timer( { timeout = 30 } )
battery_widget_timer:connect_signal("timeout", function() update_battery(battery_widget) end)
battery_widget_timer:start()
