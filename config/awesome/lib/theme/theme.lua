---------------------------
-- Default awesome theme --
---------------------------

theme = {}
theme_dir = ("/home/ch3sh1r/.config/awesome/lib/theme/")

theme.font          = "sans 8"
theme.bg_normal     = "#222222"
theme.bg_focus      = "#1e2320"
theme.bg_urgent     = "#3f3f3f"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#708090"
theme.fg_focus      = "#AAAAAA"
theme.fg_urgent     = theme.bg_urgent

theme.border_width  = 2
theme.border_normal = theme.bg_normal
theme.border_focus  = theme.fg_normal
theme.border_marked = "#91231c"

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

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = "/usr/share/awesome/themes/default/submenu.png"
theme.menu_height = 15
theme.menu_width  = 100

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

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
theme.layout_floating  = theme_dir .. "/layouts/floating.png"
theme.layout_tilebottom = theme_dir  .. "/layouts/tilebottom.png"
theme.layout_tileleft   = theme_dir .. "/layouts/tileleft.png"
theme.layout_tile = theme_dir .. "/layouts/tile.png"
theme.layout_tiletop = theme_dir .. "/layouts/tiletop.png"
theme.layout_max = theme_dir .. "/layouts/max.png"

--{{ For the Dark Theme }} --

theme.arrl = theme_dir .. "/icons/arrl.png"
theme.arrl_ld = theme_dir .. "/icons/arrl_ld.png"
theme.arrl_dl = theme_dir .. "/icons/arrl_dl.png"

--{{ For the time and date clock icon }} --
theme.clock = theme_dir .. "/icons/clock.png"

--{{ For the charging (AC adaptor) icon }} --
theme.ac = theme_dir .. "/icons/ac.png"

--{{ For the hard drive icon }} --
theme.hdd = theme_dir .. "/icons/hdd.png"

--{{ For the volume icons }} --
theme.mute = theme_dir .. "/icons/mute.png"
theme.music = theme_dir .. "/icons/music.png"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme
