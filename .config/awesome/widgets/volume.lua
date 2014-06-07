-- Volume widget
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
volumewidget = wibox.widget.textbox()
vicious.register(volumewidget, vicious.widgets.volume,
    function (widget, args)
        if (args[2] ~= "♩" ) then
            if (args[1] == 0) then volicon:set_image(beautiful.widget_vol_no)
            elseif (args[1] <= 50) then  volicon:set_image(beautiful.widget_vol_low)
            else volicon:set_image(beautiful.widget_vol)
            end
        else volicon:set_image(beautiful.widget_vol_mute)
        end
        return '<span font="Terminus 12"> <span font="Terminus 9">' .. args[1] .. '% </span></span>'
    end, 1, "Master")