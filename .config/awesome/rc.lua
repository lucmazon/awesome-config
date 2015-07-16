-- Standard awesome library
-- {{{ Imports
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
menubar = require("menubar")
vicious = require("vicious")
-- Tyrannical
tyrannical = require("tyrannical")
-- local
utils = require("settings.utils")
require("settings.errors")
properties = require("settings.properties")
machine = properties.machine
main_screen = properties.main_screen
-- }}}

-- {{{ Autostart
require("settings/autostart-" .. machine)
-- }}}



-- {{{ Variable definitions
home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
scriptdir = confdir .. "/scripts/"
themes = confdir .. "/themes"
active_theme = themes .. "/powerarrow-darker"
-- Themes define colours, icons, and wallpapers
beautiful.init(confdir .. "/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "terminator"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
gui_editor = "emacsclient -c"
browser = "firefox"
mail = "thunderbird"
tasks = terminal .. " -e htop "
file_manager = "nautilus"

-- Default modkey.
modkey = "Mod4"
altkey = "Mod1"
ctrlkey = "Control"
shiftkey = "Shift"

-- {{{ layouts
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- First, set some settings
tyrannical.settings.default_layout = awful.layout.suit.tile
tyrannical.settings.mwfact = 0.65

-- Setup some tags
tyrannical.tags = {
   { name = "a", screen = {1, 2}, class = { "Firefox", "Chromium-browser", "hipchat" } },
   { name = "u", screen = {1, 2}, class = { "Pidgin" }, exec_once = { "pidgin" }, layout = awful.layout.suit.tile.left, mwfact = 0.8 },
   { name = "i", screen = {1, 2}, class = { "Thunderbird" }, layout = awful.layout.suit.max },
   { name = "e", screen = {1, 2}, class = { "jetbrains-idea" }, layout = awful.layout.suit.fair },
   { name = "b", screen = {1, 2} },
   { name = "é", screen = {1, 2} },
   { name = "p", screen = {1, 2} },
   { name = "o", screen = {1, 2} }
}

-- Ignore the tag "exclusive" property for the following clients (matched by classes)
tyrannical.properties.intrusive = {
    "terminator", "xfce4-notifyd", "Xephyr", "Do", "Mutate"
}

-- Ignore the tiled layout for the matching clients
tyrannical.properties.floating = {
    "mypaint", "Do", "gitk", "meld", "sun-awt-X11-XDialogPeer", "Mutate"
}

tyrannical.properties.slave = {
    "terminator", "Do", "Mutate"
}

-- Make the matching clients (by classes) on top of the default layout
tyrannical.properties.ontop = {
    "Xephyr" , "ksnapshot" , "kruler", "mypaint", "Do", "Mutate"
}

-- Force the matching clients (by classes) to be centered on the screen on init
tyrannical.properties.centered = {
    "kcalc"
}

-- }}}


-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Colours
coldef  = "</span>"
colwhi  = "<span color='#b2b2b2'>"
red = "<span color='#e54c62'>"

-- {{{ Widgets
require("widgets.clock")
require("widgets.calendar")
require("widgets.mem")
require("widgets.cpu")
require("widgets.temp")
require("widgets.fs")
require("widgets.battery")
require("widgets.volume")

-- Separators
spacewidget = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)

-- }}}

-- {{{ Layout
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

    -- Create the upper wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(spacewidget)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(spacewidget)

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == tonumber(main_screen) then right_layout:add(wibox.widget.systray()) end
    right_layout:add(spacewidget)
    right_layout:add(arrl)
    right_layout:add(spacewidget)
    right_layout:add(volume.bar)
    right_layout:add(spacewidget)
    right_layout:add(arrl)
    right_layout:add(memicon)
    right_layout:add(memwidget)
    right_layout:add(arrl_ld)
    right_layout:add(cpuicon)
    right_layout:add(cpuwidget)    
    right_layout:add(arrl_dl)
    right_layout:add(tempicon)
    right_layout:add(tempwidget)
    right_layout:add(arrl_ld)
    right_layout:add(fshicon)
    right_layout:add(fshwidget)
    right_layout:add(arrl_dl)
    right_layout:add(batterywidget)
    right_layout:add(arrl)
    right_layout:add(spacewidget)
    right_layout:add(mytextclock)
    right_layout:add(spacewidget)
    right_layout:add(arrl_ld)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)    
    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myaccessories = {
    { "editor", gui_editor },
    { "file manager", file_manager }
}
myinternet = {
    { "browser", browser },
    { "mail", mail },
    { "chat", "pidgin" }
}
mygraphics = {
    { "gimp", "gimp" },
    { "inkscape", "inkscape" },
}
mydev = {
    { "idea", "idea" }
}
mysystem = {
    { "task manager", tasks }
}

myawesomemenu = {
    { "wallpaper", "random-wallpaper" },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = {
    { "accessories", myaccessories },
    { "internet", myinternet },
    { "dev", mydev },
    { "office", myoffice },
    { "graphics", mygraphics },
    { "system", mysystem },
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "open terminal", terminal }
}
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

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
    -- This is real bepo
      [0]="asterisk", "quotedbl", "guillemotleft", "guillemotright", "parenleft", "parenright", "at", "plus", "minus", "slash"
    -- This is for bepo-sbr
    -- [0]="asterisk", "quotedbl", "less", "greater", "parenleft", "parenright", "at", "plus", "minus", "slash"
}

tag_keys = {"a","u","i","e","b","é","p","o"}

view_only_tag = function (tag_index) -- # Tags # m-. ** # show tag X
    awful.tag.viewonly(awful.tag.gettags(mouse.screen)[tag_index])
end

view_toggle_tag = function (tag_index) -- # Tags # m-x ** # toggle visibility of tag X
    awful.tag.viewtoggle(awful.tag.gettags(mouse.screen)[tag_index])
end

move_to_tag = function (tag_index) -- # Tags # m-y ** # move client to tag X
    awful.client.movetotag(awful.tag.gettags(mouse.screen)[tag_index])
end

toggle_tag = function (tag_index) -- # Tags # m-, ** # place client also on tag X
    awful.client.toggletag(awful.tag.gettags(mouse.screen)[tag_index])
end

view_only_tag_mode = {}
view_toggle_tag_mode = {}
move_to_tag_mode = {}
toggle_tag_mode = {}
for tag_index, key in ipairs(tag_keys) do
    view_only_tag_mode[key] = function(c) view_only_tag(tag_index) end
    view_toggle_tag_mode[key] = function(c) view_toggle_tag(tag_index) end
    move_to_tag_mode[key] = function(c) move_to_tag(tag_index) end
    toggle_tag_mode[key] = function(c) toggle_tag(tag_index) end
end

globalkeys = awful.util.table.join(
    awful.key({ modkey }, "Left",   awful.tag.viewprev       ), -- # Tags # m-left # next tag
    awful.key({ modkey }, "Right",  awful.tag.viewnext       ), -- # Tags # m-right # previous tag
    awful.key({ modkey }, "Escape", awful.tag.history.restore), -- # Tags # m-Esc # previous tag in history
    awful.key({ modkey }, "a", -- # Tags # m-a # add tag
        function()
        awful.prompt.run({ prompt = "New tag name: " },
                    mypromptbox[mouse.screen].widget,
                    function(new_name)
                        if not new_name or #new_name == 0 then
                            return
                        else
                            props = {selected = true}
                            if tyrannical.tags_by_name[new_name] then
                               props = tyrannical.tags_by_name[new_name]
                            end
                            t = awful.tag.add(new_name, props)
                            awful.tag.viewonly(t)
                        end
                    end
                    )
        end), -- # Tags # m-d # delete tag
    awful.key({ modkey }, "d",      function()
        tag_name = awful.tag.gettags(mouse.screen)[awful.tag.getidx()].name
        awful.tag.delete()
    end),
    awful.key({ modkey }, "t", -- # Clients # m-t # next client
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "s", -- # Clients # m-s # previous client
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, shiftkey }, "t", function () awful.client.swap.byidx(  1)    end), -- # Layouts manipulation # m-S-t # swap client forward
    awful.key({ modkey, shiftkey }, "s", function () awful.client.swap.byidx( -1)    end), -- # Layouts manipulation # m-S-s # swap client backward
    awful.key({ modkey, ctrlkey  }, "t", function () awful.screen.focus_relative( 1) end), -- # Layouts manipulation # m-C-t # mouse to next screen
    awful.key({ modkey, ctrlkey  }, "s", function () awful.screen.focus_relative(-1) end), -- # Layouts manipulation # m-C-s # mouse to previous screen
    awful.key({ modkey,          }, "v", awful.client.urgent.jumpto),
    awful.key({ modkey,          }, "Tab", -- # Layouts manipulation # m-Tab # previous client in history
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,          }, "Return", function () awful.util.spawn(terminal)   end), -- # Standard # m-Enter # spawn terminal
    awful.key({ modkey, ctrlkey  }, "o",                                   awesome.restart), -- # Standard # m-C-o # restart awesome
    awful.key({ modkey, shiftkey }, "a",                                      awesome.quit), -- # Standard # m-S-a # quit awesome

    awful.key({ modkey,          }, "c",     function () awful.tag.incmwfact( 0.05)    end), -- # Standard # m-c # increase master size
    awful.key({ modkey,          }, "r",     function () awful.tag.incmwfact(-0.05)    end), -- # Standard # m-r # decrease master size
    awful.key({ modkey, shiftkey }, "c",     function () awful.tag.incnmaster( 1)      end), -- # Standard # m-S-c # increase nb columns master
    awful.key({ modkey, shiftkey }, "r",     function () awful.tag.incnmaster(-1)      end), -- # Standard # m-S-r # decrease nb columns master
    awful.key({ modkey, ctrlkey  }, "c",     function () awful.tag.incncol( 1)         end), -- # Standard # m-C-c # increase nb of columns windows
    awful.key({ modkey, ctrlkey  }, "r",     function () awful.tag.incncol(-1)         end), -- # Standard # m-C-r # decrease nb of columns windows
    awful.key({ modkey,          }, "space", function () awful.layout.inc(layouts,  1) end), -- # Standard # m-space # next layout
    awful.key({ modkey, shiftkey }, "space", function () awful.layout.inc(layouts, -1) end), -- # Standard # m-space # previous layout

    awful.key({ modkey, ctrlkey  }, "'",                              awful.client.restore), -- # Standard # m-C-' # restore client

    -- Prompt
--    awful.key({ modkey           }, "o",   function () mypromptbox[mouse.screen]:run() end),

--    awful.key({ modkey           }, "y", -- # Prompt # m-y # run lua code
        -- function ()
        --     awful.prompt.run({ prompt = "Run Lua code: " },
        --         mypromptbox[mouse.screen].widget,
        --         awful.util.eval, nil,
        --         awful.util.getdir("cache") .. "/history_eval")
        -- end),

    -- Menubar
    awful.key({ modkey           }, "j", function() menubar.show()                     end), -- # Prompt # m-j # show menubar

    -- Lock
    awful.key({ modkey, ctrlkey  }, "l", function() awful.util.spawn("slock")          end), -- # System # m-C-l # lock screen

    -- Shutdown dialog
    awful.key({ modkey, ctrlkey  }, "q", function() awful.util.spawn(scriptdir .. "shutdown_dialog") end), -- # System # m-C-q # shutdown dialog

    -- Editor (gui)
    -- awful.key({ modkey           }, "o", function() awful.util.spawn('gnome-do')            end), -- # Programs # m-o # gnome-do

    -- Keybindings
    awful.key({ modkey,          }, "h", function() naughty.notify({position = "top_left", timeout=0, text = awful.util.pread(scriptdir .. "keybindings.rb")}) end), -- # Programs # m-h # launch this popup

    awful.key({ }, "XF86AudioRaiseVolume", function()
        awful.util.spawn("amixer sset " .. volume.channel .. " " .. volume.step .. "+")
        vicious.force({ volume.bar })
        volume.notify()
        end),
    awful.key({ }, "XF86AudioLowerVolume", function()
        awful.util.spawn("amixer sset " .. volume.channel .. " " .. volume.step .. "-")
        vicious.force({ volume.bar })
        volume.notify()
    end),
    awful.key({ }, "XF86AudioMute", function()
        awful.util.spawn("amixer sset " .. volume.channel .. " toggle")
        -- The 2 following lines were needed at least on my configuration, otherwise it would get stuck muted
        awful.util.spawn("amixer sset " .. "Speaker" .. " unmute")
        awful.util.spawn("amixer sset " .. "Headphone" .. " unmute")
        vicious.force({ volume.bar })
        volume.notify()
    end),
    awful.key({ }, "XF86MonBrightnessDown", function()
	  awful.util.spawn("xbacklight -dec 10")
    end),
    awful.key({ }, "XF86MonBrightnessUp", function()
	  awful.util.spawn("xbacklight -inc 10")
    end),

    -- KEYGRABBER - Modal keybinding
    awful.key({ modkey }, ".", function(c)
        keygrabber.run(function(mod, key, event)
            if event == "release" then return true end
            keygrabber.stop()
            if view_only_tag_mode[key] then view_only_tag_mode[key](c) end
            return true
        end)
    end),
    awful.key({ modkey }, "x", function(c)
        keygrabber.run(function(mod, key, event)
            if event == "release" then return true end
            keygrabber.stop()
            if view_toggle_tag_mode[key] then view_toggle_tag_mode[key](c) end
            return true
        end)
    end),
    awful.key({ modkey }, "y", function(c)
        keygrabber.run(function(mod, key, event)
            if event == "release" then return true end
            keygrabber.stop()
            if move_to_tag_mode[key] then move_to_tag_mode[key](c) end
            return true
        end)
    end),
    awful.key({ modkey }, ",", function(c)
        keygrabber.run(function(mod, key, event)
            if event == "release" then return true end
            keygrabber.stop()
            if toggle_tag_mode[key] then toggle_tag_mode[key](c) end
            return true
        end)
    end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "e",      function (c) c.fullscreen = not c.fullscreen  end), -- # Clients # m-e # toggle fullscreen
    awful.key({ modkey            }, "k",      function (c) c:kill()                         end), -- # Clients # m-k # kill client
    awful.key({ modkey, ctrlkey }, "space",  awful.client.floating.toggle                     ), -- # Clients # m-C-space # toggle floating
    awful.key({ modkey, ctrlkey }, "Return", function (c) c:swap(awful.client.getmaster()) end), -- # Clients # m-C-Enter # swap client with master
    awful.key({ modkey,           }, "l",      awful.client.movetoscreen                        ), -- # Clients # m-l # move to next screen
    awful.key({ modkey,           }, "w",      function (c) c.ontop = not c.ontop            end), -- # Clients # m-w # place client on top
    awful.key({ modkey,           }, "'",                                                          -- # Clients # m-' # minimize client
        function (c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "n", -- # Clients # m-n # maximize client
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end), -- # Mouse # hover # focus hovered client
    awful.button({ modkey }, 1,               awful.mouse.client.move), -- # Mouse # left click # move client
    awful.button({ modkey }, 3,            awful.mouse.client.resize))  -- # Mouse # right click # resize client

-- Set keys
root.keys(globalkeys)

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "zenity" },
      properties = { floating = true } },
    { rule = { class = "meld" },
      properties = { floating = true } }
}

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

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
