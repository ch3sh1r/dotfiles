-- Window rules. See https://wiki.hypr.land/Configuring/Window-Rules/

-- Fullscreen video keeps the qs IdleMonitors (they respect inhibitors) from
-- turning the panel off or locking.
hl.window_rule({ match = { class = ".*" }, idle_inhibit = "fullscreen" })

-- Apps asking to maximize themselves get tiled like everything else.
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Portal and file-chooser dialogs float instead of taking a tile.
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true })
hl.window_rule({
	match = {
		class = "(org.gnome.Nautilus|brave-browser|Brave-browser)",
		title = "^(Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[Cc]hoose.*)",
	},
	float = true,
})

-- Scroll nicely in the terminal.
hl.window_rule({ match = { class = "Alacritty" }, scroll_touchpad = 1.5 })
