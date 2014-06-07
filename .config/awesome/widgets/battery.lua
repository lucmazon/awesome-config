-- Battery widget
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_battery)

function batstate()

    local file = io.open("/sys/class/power_supply/BAT0/status", "r")

    if (file == nil) then
        return "Cable plugged"
    end

    local batstate = file:read("*line")
    file:close()

    if (batstate == 'Discharging' or batstate == 'Charging') then
        return batstate
    else
        return "Fully charged"
    end
end

batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat,
    function (widget, args)
    -- plugged
        if (batstate() == 'Cable plugged') then
            baticon:set_image(beautiful.widget_ac)
            return '<span font="Terminus 12"> <span font="Terminus 9">AC </span></span>'
            -- critical
        elseif (args[2] <= 5 and batstate() == 'Discharging') then
            baticon:set_image(beautiful.widget_battery_empty)
            naughty.notify({
                text = "sto per spegnermi...",
                title = "Carica quasi esaurita!",
                position = "top_right",
                timeout = 1,
                fg="#000000",
                bg="#ffffff",
                screen = 1,
                ontop = true,
            })
            -- low
        elseif (args[2] <= 10 and batstate() == 'Discharging') then
            baticon:set_image(beautiful.widget_battery_low)
            naughty.notify({
                text = "attacca il cavo!",
                title = "Carica bassa",
                position = "top_right",
                timeout = 1,
                fg="#ffffff",
                bg="#262729",
                screen = 1,
                ontop = true,
            })
        else baticon:set_image(beautiful.widget_battery)
        end
        return '<span font="Terminus 12"> <span font="Terminus 9">' .. args[2] .. '% </span></span>'
    end, 1, 'BAT0')