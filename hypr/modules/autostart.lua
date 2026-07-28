local commands = {
  "~/.config/hypr/scripts/hypridle-start",
  "hyprsunset",
  "iio-hyprland DSI-1",
  "swaybg -c 282a36 -m fit -i ~/.config/hypr/rune.png",
  "qs",
  "wl-paste --watch cliphist store",
}

hl.on("hyprland.start", function()
  for _, command in ipairs(commands) do
    hl.exec_cmd(command)
  end
end)
