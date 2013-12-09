---------------------------
-- Default awesome theme --
---------------------------

theme = {}
theme_dir = ("/home/ch3sh1r/.config/awesome/lib/theme/")

theme.font          = "terminus 9"
theme.bg_normal     = "#3c3b37"
theme.bg_urgent     = theme.bg_normal
theme.bg_focus      = theme.bg_normal
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#708090"
theme.fg_focus      = "#AAAAAA"
theme.fg_urgent     = theme.bg_urgent

theme.border_width  = 2
theme.border_normal = theme.bg_normal
theme.border_focus  = theme.fg_focus
theme.border_marked = theme.fg_normal

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel   = theme_dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel = theme_dir .. "/icons/square_unsel.png"

-- Define the image to load
theme.titlebar_close_button_normal = "/usr/share/awesome/themes/default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = "/usr/share/awesome/themes/default/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = "/usr/share/awesome/themes/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = "/usr/share/awesome/themes/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = "/usr/share/awesome/themes/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = "/usr/share/awesome/themes/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = "/usr/share/awesome/themes/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = "/usr/share/awesome/themes/default/titlebar/maximized_focus_active.png"

theme.wallpaper = theme_dir .. "/pattern.png"

-- You can use your own layout icons like this:
theme.layout_floating  = theme_dir .. "/icons/floating.png"
theme.layout_tilebottom = theme_dir  .. "/icons/tilebottom.png"
theme.layout_tileleft   = theme_dir .. "/icons/tileleft.png"
theme.layout_tile = theme_dir .. "/icons/tile.png"
theme.layout_tiletop = theme_dir .. "/icons/tiletop.png"
theme.layout_max = theme_dir .. "/icons/max.png"

--{{ For the charging (AC adaptor) icon }} --
theme.ac_full = theme_dir .. "/icons/ac_full.png"
theme.ac_medb = theme_dir .. "/icons/ac_medb.png"
theme.ac_med = theme_dir .. "/icons/ac_med.png"
theme.ac_medl = theme_dir .. "/icons/ac_medl.png"
theme.ac_low = theme_dir .. "/icons/ac_low.png"

--{{ For the volume icons }} --
theme.mute = theme_dir .. "/icons/mute.png"
theme.music = theme_dir .. "/icons/music.png"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme
