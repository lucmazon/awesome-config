-- MEM widget
hudsonwidget = wibox.widget.textbox()
hudsonwidget:set_markup(awful.util.pread(scriptdir .. "hudson.rb"))

mytimer = timer({ timeout = 10 })
mytimer:connect_signal("timeout", function() hudsonwidget:set_markup(awful.util.pread(scriptdir .. "hudson.rb")) end)
mytimer:start()
