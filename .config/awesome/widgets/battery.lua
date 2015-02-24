batterywidget = wibox.widget.textbox()
batterywidget:set_markup(awful.util.pread(scriptdir .. "battery.rb"))

mytimer = timer({ timeout = 10 })
mytimer:connect_signal("timeout", function() batterywidget:set_markup(awful.util.pread(scriptdir .. "battery.rb")) end)
mytimer:start()
