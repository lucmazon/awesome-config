-- Temp widget
tempicon = wibox.widget.imagebox()
tempicon:set_image(beautiful.widget_temp)
tempicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e sudo powertop ", false) end)))
tempwidget = wibox.widget.textbox()
vicious.register(tempwidget, vicious.widgets.thermal, ' $1°C ', 9, {"coretemp.0", "core"} )