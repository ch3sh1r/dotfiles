--------------------------------------
--     "Zenburn" awesome theme      --
--       By Adrian C. (anrxc)       --
-- corrected by Alexey B. (ch3sh1r) --
--------------------------------------

-- {{{ Main
    theme = {}
    local home      = os.getenv("HOME")
    local config    = home .. "/.config/awesome/"
    theme.wallpaper = config .. "/themes/zenburn/zenburn-background.png"
-- }}}

-- {{{ Styles
    theme.font      = "ubuntu 8"

    -- {{{ Colors
        theme.fg_normal  = "#dcdccc"
        theme.fg_focus   = "#f0dfaf"
        theme.fg_urgent  = "#cc9393"
        theme.bg_normal  = "#3c3b37"
        theme.bg_focus   = "#1e2320"
        theme.bg_urgent  = "#3f3f3f"
        theme.bg_systray = theme.bg_normal
    -- }}}

    -- {{{ borders
        theme.border_width  = 2
        theme.border_normal = "#3f3f3f"
        theme.border_focus  = "#6f6f6f"
        theme.border_marked = "#cc9393"
    -- }}}

    -- {{{ titlebars
        theme.titlebar_bg_focus  = "#3f3f3f"
        theme.titlebar_bg_normal = "#3f3f3f"
    -- }}}

    -- there are other variable sets
    -- overriding the default one when
    -- defined, the sets are:
    -- [taglist|tasklist]_[bg|fg]_[focus|urgent]
    -- titlebar_[normal|focus]
    -- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
    -- example:
    --theme.taglist_bg_focus = "#cc9393"
-- }}}

-- {{{ widgets
    -- you can add as many variables as
    -- you wish and access them by using
    -- beautiful.variable in your rc.lua
    --theme.fg_widget        = "#aecf96"
    --theme.fg_center_widget = "#88a175"
    --theme.fg_end_widget    = "#ff5656"
    --theme.bg_widget        = "#494b4f"
    --theme.border_widget    = "#3f3f3f"
-- }}}

-- {{{ mouse finder
    theme.mouse_finder_color = "#cc9393"
    -- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ menu
    -- variables set for theming the menu:
    -- menu_[bg|fg]_[normal|focus]
    -- menu_[border_color|border_width]
    theme.menu_height = 15
    theme.menu_width  = 100
-- }}}

-- {{{ icons
    -- {{{ taglist
        theme.taglist_squares_sel   = config .. "/themes/zenburn/taglist/squarefz.png"
        theme.taglist_squares_unsel = config .. "/themes/zenburn/taglist/squarez.png"
        --theme.taglist_squares_resize = "false"
    -- }}}

    -- {{{ misc
        theme.awesome_icon           = config .. "/themes/zenburn/awesome-icon.png"
        theme.menu_submenu_icon      = config .. "/themes/default/submenu.png"
    -- }}}

    -- {{{ layout
        theme.layout_tile       = config .. "/themes/zenburn/layouts/tile.png"
        theme.layout_tileleft   = config .. "/themes/zenburn/layouts/tileleft.png"
        theme.layout_tilebottom = config .. "/themes/zenburn/layouts/tilebottom.png"
        theme.layout_tiletop    = config .. "/themes/zenburn/layouts/tiletop.png"
        theme.layout_fairv      = config .. "/themes/zenburn/layouts/fairv.png"
        theme.layout_fairh      = config .. "/themes/zenburn/layouts/fairh.png"
        theme.layout_spiral     = config .. "/themes/zenburn/layouts/spiral.png"
        theme.layout_dwindle    = config .. "/themes/zenburn/layouts/dwindle.png"
        theme.layout_max        = config .. "/themes/zenburn/layouts/max.png"
        theme.layout_fullscreen = config .. "/themes/zenburn/layouts/fullscreen.png"
        theme.layout_magnifier  = config .. "/themes/zenburn/layouts/magnifier.png"
        theme.layout_floating   = config .. "/themes/zenburn/layouts/floating.png"
    -- }}}

    -- {{{ titlebar
        theme.titlebar_close_button_focus  = config .. "/themes/zenburn/titlebar/close_focus.png"
        theme.titlebar_close_button_normal = config .. "/themes/zenburn/titlebar/close_normal.png"

        theme.titlebar_ontop_button_focus_active    = config .. "/themes/zenburn/titlebar/ontop_focus_active.png"
        theme.titlebar_ontop_button_normal_active   = config .. "/themes/zenburn/titlebar/ontop_normal_active.png"
        theme.titlebar_ontop_button_focus_inactive  = config .. "/themes/zenburn/titlebar/ontop_focus_inactive.png"
        theme.titlebar_ontop_button_normal_inactive = config .. "/themes/zenburn/titlebar/ontop_normal_inactive.png"

        theme.titlebar_sticky_button_focus_active    = config .. "/themes/zenburn/titlebar/sticky_focus_active.png"
        theme.titlebar_sticky_button_normal_active   = config .. "/themes/zenburn/titlebar/sticky_normal_active.png"
        theme.titlebar_sticky_button_focus_inactive  = config .. "/themes/zenburn/titlebar/sticky_focus_inactive.png"
        theme.titlebar_sticky_button_normal_inactive = config .. "/themes/zenburn/titlebar/sticky_normal_inactive.png"

        theme.titlebar_floating_button_focus_active    = config .. "/themes/zenburn/titlebar/floating_focus_active.png"
        theme.titlebar_floating_button_normal_active   = config .. "/themes/zenburn/titlebar/floating_normal_active.png"
        theme.titlebar_floating_button_focus_inactive  = config .. "/themes/zenburn/titlebar/floating_focus_inactive.png"
        theme.titlebar_floating_button_normal_inactive = config .. "/themes/zenburn/titlebar/floating_normal_inactive.png"

        theme.titlebar_maximized_button_focus_active    = config .. "/themes/zenburn/titlebar/maximized_focus_active.png"
        theme.titlebar_maximized_button_normal_active   = config .. "/themes/zenburn/titlebar/maximized_normal_active.png"
        theme.titlebar_maximized_button_focus_inactive  = config .. "/themes/zenburn/titlebar/maximized_focus_inactive.png"
        theme.titlebar_maximized_button_normal_inactive = config .. "/themes/zenburn/titlebar/maximized_normal_inactive.png"
    -- }}}
-- }}}

return theme
