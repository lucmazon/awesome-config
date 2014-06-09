-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev),
    awful.button({ }, 10, function() awful.util.spawn("slock") end)
))
-- }}}

-- Bepoified
local bepo_numkeys = {
    -- bépo à 4 touches +-/*
    [0]="at", "plus", "minus", "slash", "asterisk"
    -- This is real bepo
    --   [0]="asterisk", "quotedbl", "guillemotleft", "guillemotright", "parenleft", "parenright", "at", "plus", "minus", "slash"
    -- This is for bepo-sbr
    -- [0]="asterisk", "quotedbl", "less", "greater", "parenleft", "parenright", "at", "plus", "minus", "slash"
}

globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "t",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "s",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "t", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "s", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "t", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "s", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "v", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "o", awesome.restart),
    awful.key({ modkey, "Shift"   }, "a", awesome.quit),

    awful.key({ modkey,           }, "r",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "c",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "c",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "r",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "c",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "r",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "'", awful.client.restore),

    -- Prompt
    awful.key({ modkey }, "o", function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "y",
        function ()
            awful.prompt.run({ prompt = "Run Lua code: " },
                mypromptbox[mouse.screen].widget,
                awful.util.eval, nil,
                awful.util.getdir("cache") .. "/history_eval")
        end),
    -- Menubar
    awful.key({ modkey }, "j", function() menubar.show() end),

    -- Dropdown terminal
    awful.key({ modkey }, "$", function() scratch.drop(terminal) end),

    -- Lock
    awful.key({ modkey, "Control" }, "l", function() awful.util.spawn("slock") end),

    -- Shutdown dialog
    awful.key({ modkey, "Control" }, "q", function() awful.util.spawn(scriptdir .. "shutdown_dialog") end),

    -- Editor (gui)
    awful.key({ modkey}, "p", function() awful.util.spawn(gui_editor) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "e",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey            }, "k",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "l",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "w",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "'",
        function (c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "n",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, bepo_numkeys[i],
            function ()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                    awful.tag.viewonly(tag)
                end
            end),
        awful.key({ modkey, "Control" }, bepo_numkeys[i],
            function ()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end),
        awful.key({ modkey, "Shift" }, bepo_numkeys[i],
            function ()
                local tag = awful.tag.gettags(client.focus.screen)[i]
                if client.focus and tag then
                    awful.client.movetotag(tag)
                end
            end),
        awful.key({ modkey, "Control", "Shift" }, bepo_numkeys[i],
            function ()
                local tag = awful.tag.gettags(client.focus.screen)[i]
                if client.focus and tag then
                    awful.client.toggletag(tag)
                end
            end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)