-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
local shifty = require("lib/shifty")

-- {{{ Error handling
    -- Check if awesome encountered an error during startup and fell back to
    -- another config (This code will only ever execute for the fallback config)
    if awesome.startup_errors then
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, there were errors during startup!",
                         text = awesome.startup_errors })
    end

    -- Handle runtime errors after startup
    do
        local in_error = false
        awesome.connect_signal("debug::error", function (err)
            -- Make sure we don't go into an endless error loop
            if in_error then return end
            in_error = true

            naughty.notify({ preset = naughty.config.presets.critical,
                             title = "Oops, an error happened!",
                             text = err })
            in_error = false
        end)
    end
-- }}}

-- {{{ Variable definitions
    -- Themes define colours, icons, and wallpapers
    theme_dir = ("/home/ch3sh1r/.config/awesome/lib/theme/")
    beautiful.init(theme_dir .. "theme.lua")

    -- This is used later as the default terminal, browser and editor to run.
    terminal = "gnome-terminal"
    editor = "vim"
    editor_cmd = terminal .. " -e " .. editor
    editor_gui = "gvim"
    browser = "firefox"
    file_manager = "nautilus --no-desktop"

    -- Powerarrow-dark separators
    arrl = wibox.widget.imagebox()
    arrl:set_image(beautiful.arrl)
    arrl_ld = wibox.widget.imagebox()
    arrl_ld:set_image(beautiful.arrl_ld)
    arrl_dl = wibox.widget.imagebox()
    arrl_dl:set_image(beautiful.arrl_dl)

    -- Default modkey.
    modkey = "Mod4"

    -- Table of layouts to cover with awful.layout.inc, order matters.
    local layouts =
    {
        awful.layout.suit.floating,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.max,
        --awful.layout.suit.spiral,
        --awful.layout.suit.fair,
        --awful.layout.suit.fair.horizontal,
        --awful.layout.suit.spiral.dwindle,
        --awful.layout.suit.max.fullscreen,
        --awful.layout.suit.magnifier,
    }
-- }}}

-- {{{ Wallpaper
    if beautiful.wallpaper then
        for s = 1, screen.count() do
            gears.wallpaper.tiled(beautiful.wallpaper, s)
        end
    end
-- }}}

-- {{{ Shifty
    -- Shifty configured tags.
    shifty.config.tags = {
        def = {
            layout    = awful.layout.suit.tile.left,
            mwfact    = 0.5,
            exclusive = false,
            position  = 2,
            init      = true,
            screen    = 1,
            slave     = true,
        },
        web = {
            layout      = awful.layout.suit.tile.left,
            mwfact      = 0.35,
            exclusive   = false,
            max_clients = 1,
            position    = 1,
            spawn       = browser,
        },
        media = {
            layout    = awful.layout.suit.float,
            exclusive = false,
            position  = 6,
        },
        virtual = {
            layout    = awful.layout.suit.tile.left,
            exclusive = false,
            spawn     = virtual,
            position  = 7,
        },
        office = {
            layout    = awful.layout.suit.tile.left,
            position  = 8,
        },
        mail = {
            layout    = awful.layout.suit.tile.left,
            mwfact    = 0.4,
            exclusive = false,
            position  = 9,
            spawn     = mail,
            slave     = true
        },
    }

    -- Shifty application matching rules
    -- order here matters, early rules will be applied first
    shifty.config.apps = {
        {
            match = { "Navigator", },
            tag = "web",
        },
        {
            match = { "Thunderbird", "mutt", },
            tag = "mail",
        },
        {
            match = { "LibreOffice.*", },
            tag = "office",
        },
        {
            match = { "gimp", "easytag", },
            tag = "media",
            nopopup = true,
        },
        {
            match = { "Pidgin", "Skype", },
            slave = true,
            float = true,
        },
        {
            match = { "VirtualBox", "vmware" },
            tag = "virtual",
            nopopup = true,
        },
        {
            match = {""},
            buttons = awful.util.table.join(
                awful.button({}, 1, function (c) client.focus = c; c:raise() end),
                awful.button({modkey}, 1, function(c)
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                    end),
                awful.button({modkey}, 3, awful.mouse.client.resize)
                )
        },
    }

    -- Shifty default tag creation rules
    -- parameter description
    shifty.config.defaults = {
        layout = awful.layout.suit.tile.left,
        ncol = 1,
        mwfact = 0.60,
        floatBars = true,
        guess_name = true,
        guess_position = false,
    }
-- }}}

-- {{{ Wibox
    -- Create a textclock widget
    mytextclock = awful.widget.textclock()

    -- Battery Widget
    batwidget = wibox.widget.textbox()
    vicious.register(batwidget, vicious.widgets.bat, '<span font="Inconsolata 11" color="#AAAAAA" background="#313131">$1$2% $3 </span>', 120, "BAT1")
    baticon = wibox.widget.imagebox()
    baticon:set_image(beautiful.ac)

    -- Volume Widget
    volume = wibox.widget.textbox()
    vicious.register(volume, vicious.widgets.volume, '<span font="Inconsolata 11" color="#AAAAAA" background="#1e2320">$1% </span>', 1, "Master")
    volumeicon = wibox.widget.imagebox()
    vicious.register(volumeicon, vicious.widgets.volume, function(widget, args)
            local paraone = tonumber(args[1])
            if args[2] == "♩" or paraone == 0 then
                    volumeicon:set_image(beautiful.mute)
            elseif paraone >= 33 and paraone <= 100 then
                    volumeicon:set_image(beautiful.music)
            else
                    volumeicon:set_image(beautiful.music)
            end
    end, 120, "Master")

    -- Time and Date Widget
    tdwidget = wibox.widget.textbox()
    vicious.register(tdwidget, vicious.widgets.date, '<span font="Inconsolata 11" color="#AAAAAA" background="#313131"> %b %d %R </span>', 20)
    clockicon = wibox.widget.imagebox()
    clockicon:set_image(beautiful.clock)

    -- Create a wibox for each screen and add it
    mywibox = {}
    mypromptbox = {}
    mylayoutbox = {}
    mytaglist = {}
    mytaglist.buttons = awful.util.table.join(
                        awful.button({ }, 1, awful.tag.viewonly),
                        awful.button({ modkey }, 1, awful.client.movetotag),
                        awful.button({ }, 3, awful.tag.viewtoggle),
                        awful.button({ modkey }, 3, awful.client.toggletag),
                        awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                        awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                        )
    mytasklist = {}
    mytasklist.buttons = awful.util.table.join(
                         awful.button({ }, 1, function (c)
                                                  if c == client.focus then
                                                      c.minimized = true
                                                  else
                                                      -- Without this, the following
                                                      -- :isvisible() makes no sense
                                                      c.minimized = false
                                                      if not c:isvisible() then
                                                          awful.tag.viewonly(c:tags()[1])
                                                      end
                                                      -- This will also un-minimize
                                                      -- the client, if needed
                                                      client.focus = c
                                                      c:raise()
                                                  end
                                              end),
                         awful.button({ }, 3, function ()
                                                  if instance then
                                                      instance:hide()
                                                      instance = nil
                                                  else
                                                      instance = awful.menu.clients({ width=250 })
                                                  end
                                              end),
                         awful.button({ }, 4, function ()
                                                  awful.client.focus.byidx(1)
                                                  if client.focus then client.focus:raise() end
                                              end),
                         awful.button({ }, 5, function ()
                                                  awful.client.focus.byidx(-1)
                                                  if client.focus then client.focus:raise() end
                                              end))

    for s = 1, screen.count() do
        -- Create a promptbox for each screen
        mypromptbox[s] = awful.widget.prompt()
        -- Create an imagebox widget which will contains an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        mylayoutbox[s] = awful.widget.layoutbox(s)
        mylayoutbox[s]:buttons(awful.util.table.join(
                               awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                               awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                               awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                               awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
        -- Create a taglist widget
        mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

        -- Create a tasklist widget
        mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

        -- Create the wibox
        mywibox[s] = awful.wibox({ position = "top", screen = s, height = "16" })

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(mytaglist[s])
        left_layout:add(mypromptbox[s])

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        if s == 1 then right_layout:add(wibox.widget.systray()) end
        right_layout:add(arrl_ld)
        right_layout:add(baticon)
        right_layout:add(batwidget)
        right_layout:add(arrl_dl)
        right_layout:add(volumeicon)
        right_layout:add(volume)
        right_layout:add(arrl_ld)
        right_layout:add(clockicon)
        right_layout:add(tdwidget)
        right_layout:add(arrl_dl)
        right_layout:add(mylayoutbox[s])

        -- Now bring it all together (with the tasklist in the middle)
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_middle(mytasklist[s])
        layout:set_right(right_layout)
        mywibox[s]:set_widget(layout)
    end
-- }}}

-- {{{ Key bindings
    globalkeys = awful.util.table.join(
        awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
        awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
        awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

        -- Shifty keybindings
        awful.key({ modkey,           }, "d", shifty.del),
        awful.key({ modkey,           }, "i", shifty.rename),
        awful.key({ modkey,           }, "a", shifty.add),

        awful.key({ modkey,           }, "j",
            function ()
                awful.client.focus.byidx( 1)
                if client.focus then client.focus:raise() end
            end),
        awful.key({ modkey,           }, "k",
            function ()
                awful.client.focus.byidx(-1)
                if client.focus then client.focus:raise() end
            end),

        -- Layout manipulation
        awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
        awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
        awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
        awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
        awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
        awful.key({ modkey,           }, "Tab",
            function ()
                awful.client.focus.history.previous()
                if client.focus then
                    client.focus:raise()
                end
            end),

        -- Brightness manipulation
        awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -dec 15") end),
        awful.key({ }, "XF86MonBrightnessUp",   function () awful.util.spawn("xbacklight -inc 15") end),

        -- MDP manipulation
        awful.key({ }, "XF86AudioNext", function () awful.util.spawn("/home/ch3sh1r/.config/awesome/bin/mpd_next") end),
        awful.key({ }, "XF86AudioPrev", function () awful.util.spawn("/home/ch3sh1r/.config/awesome/bin/mpd_prev") end),
        awful.key({ }, "XF86AudioPlay", function () awful.util.spawn("/home/ch3sh1r/.config/awesome/bin/mpd_playpause") end),
        awful.key({ }, "XF86AudioStop", function () awful.util.spawn("/home/ch3sh1r/.config/awesome/bin/mpd_stop") end),

        -- Sound manipulation
        awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master 9%+") end),
        awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master 9%-") end),
        awful.key({ }, "XF86AudioMute",        function () awful.util.spawn("amixer sset Master toggle") end),

        -- Standard program
        awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
        awful.key({ modkey, "Shift"   }, "n", function () awful.util.spawn(file_manager) end),
        awful.key({ modkey, "Shift"   }, "f", function () awful.util.spawn(browser) end),
        awful.key({ modkey, "Shift"   }, "t", function () awful.util.spawn("thunderbird") end),
        awful.key({ modkey, "Shift"   }, "p", function () awful.util.spawn("pidgin") end),
        awful.key({ modkey, "Shift"   }, "s", function () awful.util.spawn("skype") end),
        awful.key({ modkey, "Shift"   }, "w", function () awful.util.spawn("vmware") end),
        awful.key({ modkey, "Shift"   }, "v", function () awful.util.spawn("virtualbox") end),

        awful.key({ modkey, "Control" }, "l", function () awful.util.spawn("gnome-screensaver-command --lock") end),
        awful.key({ modkey, "Control" }, "r", awesome.restart),
        awful.key({ modkey, "Shift"   }, "q", awesome.quit),

        awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05) end),
        awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05) end),
        awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1) end),
        awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1) end),
        awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1) end),
        awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1) end),
        awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
        awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

        awful.key({ modkey, "Control" }, "n", awful.client.restore),

        -- Prompt
        awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

        -- Menubar
        awful.key({ modkey, "Shift"   }, "r", function() menubar.show() end),

        -- Run Lua code
        awful.key({ modkey }, "x",
                  function ()
                      awful.prompt.run({ prompt = "Run Lua code: " },
                      mypromptbox[mouse.screen].widget,
                      awful.util.eval, nil,
                      awful.util.getdir("cache") .. "/history_eval")
                  end)
    )

    clientkeys = awful.util.table.join(
        awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
        awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill() end),
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
        awful.key({ modkey,           }, "o",      awful.client.movetoscreen),
        awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop end),
        awful.key({ modkey,           }, "n",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end),
        awful.key({ modkey,           }, "m",
            function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c.maximized_vertical   = not c.maximized_vertical
            end)
    )

    -- Bind all key numbers to tags.
    -- Be careful: we use keycodes to make it works on any keyboard layout.
    -- This should map on the top row of your keyboard, usually 1 to 9.
    for i = 1, 9 do
        globalkeys = awful.util.table.join(
                            globalkeys,
                            awful.key({modkey}, i,
                                function()
                                    awful.tag.viewonly(shifty.getpos(i))
                                end))
        globalkeys = awful.util.table.join(
                            globalkeys,
                            awful.key({modkey, "Control"}, i,
                                function ()
                                    local t = shifty.getpos(i)
                                    t.selected = not t.selected
                                end))
        globalkeys = awful.util.table.join(globalkeys,
                                    awful.key({modkey, "Control", "Shift"}, i,
                    function ()
                        if client.focus then
                            awful.client.toggletag(shifty.getpos(i))
                        end
                    end))
        -- move clients to other tags
        globalkeys = awful.util.table.join(
                        globalkeys,
                        awful.key({modkey, "Shift"}, i,
                            function ()
                                if client.focus then
                                    local t = shifty.getpos(i)
                                    awful.client.movetotag(t)
                                    awful.tag.viewonly(t)
                                end
                            end))
    end

    clientbuttons = awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ modkey }, 1, awful.mouse.client.move),
        awful.button({ modkey }, 3, awful.mouse.client.resize))

    -- Bind all key numbers to tags.
    -- Be careful: we use keycodes to make it works on any keyboard layout.
    -- This should map on the top row of your keyboard, usually 1 to 9.
    for i = 1, (shifty.config.maxtags or 9) do
        globalkeys = awful.util.table.join(globalkeys,
            awful.key({ modkey }, "#" .. i + 9,
                      function ()
                          awful.tag.viewonly(shifty.getpos(i))
                      end),
            awful.key({ modkey, "Control" }, "#" .. i + 9,
                      function ()
                          awful.tag.viewtoggle(shifty.getpos(i))
                      end),
            awful.key({ modkey, "Shift" }, "#" .. i + 9,
                      function ()
                          if client.focus then
                              local t = shifty.getpos(i)
                              awful.client.movetotag(t)
                              awful.tag.viewonly(t)
                           end
                      end),
            awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                      function ()
                          if client.focus then
                              awful.client.toggletag(shifty.getpos(i))
                          end
                      end))
    end

    -- Set keys
    root.keys(globalkeys)

    -- Initialize shifty
    -- the assignment of shifty.taglist must always be after its actually
    -- initialized with awful.widget.taglist.new()
    shifty.config.clientkeys = clientkeys
    shifty.config.modkey = modkey
    shifty.taglist = mytaglist
    shifty.init()
-- }}}

-- {{{ Signals
    -- Signal function to execute when a new client appears.
    client.connect_signal("manage", function (c, startup)
        -- Enable sloppy focus
        c:connect_signal("mouse::enter", function(c)
            if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                and awful.client.focus.filter(c) then
                client.focus = c
            end
        end)

        -- Disable gaps between terminals.
        c.size_hints_honor = false

        if not startup then
            -- Set the windows at the slave,
            -- i.e. put it at the end of others instead of setting it master.
            -- awful.client.setslave(c)

            -- Put windows in a smart way, only if they does not set an initial position.
            if not c.size_hints.user_position and not c.size_hints.program_position then
                awful.placement.no_overlap(c)
                awful.placement.no_offscreen(c)
            end
        end
    end)

    client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
    client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{ Function to ensure that certain programs only have one
-- instance of themselves when i restart awesome
    function run_once(cmd)
            findme = cmd
            firstspace = cmd:find(" ")
            if firstspace then
                    findme = cmd:sub(0, firstspace-1)
            end
            awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
    end
-- }}

-- {{{ Autostart
    --awful.util.spawn_with_shell("dropbox start -i")
    --awful.util.spawn_with_shell("runone everpad")
    awful.util.spawn_with_shell("setxkbmap -layout 'us,ru' -option 'grp:alt_shift_toggle'")
    awful.util.spawn_with_shell("setxkbmap -option caps:escape")
    awful.util.spawn_with_shell('xinput --set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1')
    awful.util.spawn_with_shell('xinput --set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2')
    awful.util.spawn_with_shell('xinput --set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200')
    awful.util.spawn_with_shell('xinput --set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5')
    run_once("gnome-screensaver")
    run_once("nm-applet")
-- }}}
