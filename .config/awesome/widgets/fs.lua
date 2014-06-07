-- /home fs widget
fshicon = wibox.widget.imagebox()
fshicon:set_image(beautiful.widget_hdd)
fshwidget = wibox.widget.textbox()
vicious.register(fshwidget, vicious.widgets.fs,
    function (widget, args)
        if args["{/ used_p}"] >= 95 and args["{/ used_p}"] < 99 then
            return '<span background="#313131" font="Terminus 13" rise="2000"> <span font="Terminus 9">' .. args["{/home used_p}"] .. '% </span></span>'
        elseif args["{/ used_p}"] >= 99 and args["{/ used_p}"] <= 100 then
            naughty.notify({ title = "Attenzione", text = "Partizione /home esaurita!\nFa' un po' di spazio.",
                timeout = 10,
                position = "top_right",
                fg = beautiful.fg_urgent,
                bg = beautiful.bg_urgent })
            return '<span background="#313131" font="Terminus 13" rise="2000"> <span font="Terminus 9">' .. args["{/ used_p}"] .. '% </span></span>'
        else
            return '<span background="#313131" font="Terminus 13" rise="2000"> <span font="Terminus 9">' .. args["{/ used_p}"] .. '% </span></span>'
        end
    end, 600)


local infos = nil

function remove_info()
    if infos ~= nil then
        naughty.destroy(infos)
        infos = nil
    end
end

function add_info()
    remove_info()
    local capi = {
        mouse = mouse,
        screen = screen
    }
    local cal = awful.util.pread(scriptdir .. "dfs")
    cal = string.gsub(cal, "          ^%s*(.-)%s*$", "%1")
    infos = naughty.notify({
        text = string.format('<span font_desc="%s">%s</span>', "Terminus", cal),
        timeout = 0,
        position = "top_right",
        margin = 10,
        height = 170,
        width = 585,
        screen	= capi.mouse.screen
    })
end

fshwidget:connect_signal('mouse::enter', function () add_info() end)
fshwidget:connect_signal('mouse::leave', function () remove_info() end)
fshicon:connect_signal('mouse::enter', function () add_info() end)
fshicon:connect_signal('mouse::leave', function () remove_info() end)