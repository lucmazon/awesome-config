-- see this blogpost to change your default sound card: http://ptspts.blogspot.fr/2009/03/how-to-select-alsa-sound-card-and-have.html

volume =
{
	channel = "Master",
	step = "5%",
	colors =
	{
		unmute = "#AECF96",
		mute = "#FF5656"
	},
	mixer = terminal .. " -e alsamixer", -- or whatever your preferred sound mixer is
	notifications =
	{
		icons =
		{
			-- the first item is the 'muted' icon
			"/usr/share/icons/gnome/48x48/status/audio-volume-muted.png",
			-- the rest of the items correspond to intermediate volume levels - you can have as many as you want (but must be >= 1)
			"/usr/share/icons/gnome/48x48/status/audio-volume-low.png",
			"/usr/share/icons/gnome/48x48/status/audio-volume-medium.png",
			"/usr/share/icons/gnome/48x48/status/audio-volume-high.png"
		},
		font = "Monospace 11", -- must be a monospace font for the bar to be sized consistently
		icon_size = 48,
		bar_size = 20 -- adjust to fit your font if the bar doesn't fit
	}
}
-- widget
volume.bar = awful.widget.progressbar ()
volume.bar:set_width (8)
volume.bar:set_vertical (true)
volume.bar:set_background_color ("#494B4F")
volume.bar:set_color (volume.colors.unmute)
volume.bar:buttons (awful.util.table.join (
	awful.button ({}, 1, function()
		awful.util.spawn (volume.mixer)
	end),
	awful.button ({}, 3, function()
		awful.util.spawn ("amixer sset " .. volume.channel .. " toggle")
		vicious.force ({ volume.bar })
	end),
	awful.button ({}, 4, function()
		awful.util.spawn ("amixer sset " .. volume.channel .. " " .. volume.step .. "+")
		vicious.force ({ volume.bar })
	end),
	awful.button ({}, 5, function()
		awful.util.spawn ("amixer sset " .. volume.channel .. " " .. volume.step .. "-")
		vicious.force ({ volume.bar })
	end)
))
-- tooltip
volume.tooltip = awful.tooltip ({ objects = { volume.bar } })
-- naughty notifications
volume._current_level = 0
volume._muted = false
function volume:notify ()
	local preset =
	{
		height = 75,
		width = 300,
		font = volume.notifications.font
	}
	local i = 1;
	while volume.notifications.icons[i + 1] ~= nil
	do
		i = i + 1
	end
	if i >= 2
	then
		preset.icon_size = volume.notifications.icon_size
		if volume._muted or volume._current_level == 0
		then
			preset.icon = volume.notifications.icons[1]
		elseif volume._current_level == 100
		then
			preset.icon = volume.notifications.icons[i]
		else
			local int = math.modf (volume._current_level / 100 * (i - 1))
			preset.icon = volume.notifications.icons[int + 2]
		end
	end
	if volume._muted
	then
		preset.title = volume.channel .. " - Muted"
	elseif volume._current_level == 0
	then
		preset.title = volume.channel .. " - 0% (muted)"
		preset.text = "[" .. string.rep (" ", volume.notifications.bar_size) .. "]"
	elseif volume._current_level == 100
	then
		preset.title = volume.channel .. " - 100% (max)"
		preset.text = "[" .. string.rep ("|", volume.notifications.bar_size) .. "]"
	else
		local int = math.modf (volume._current_level / 100 * volume.notifications.bar_size)
		preset.title = volume.channel .. " - " .. volume._current_level .. "%"
		preset.text = "[" .. string.rep ("|", int) .. string.rep (" ", volume.notifications.bar_size - int) .. "]"
	end
	if volume._notify ~= nil
	then

		volume._notify = naughty.notify (
		{
			replaces_id = volume._notify.id,
			preset = preset
		})
	else
		volume._notify = naughty.notify ({ preset = preset })
	end
end
-- register the widget through vicious
vicious.register (volume.bar, vicious.widgets.volume, function (widget, args)
	volume._current_level = args[1]
	if args[2] == "♩"
	then
		volume._muted = true
		volume.tooltip:set_text (" [Muted] ")
		widget:set_color (volume.colors.mute)
		return 100
	end
	volume._muted = false
	volume.tooltip:set_text (" " .. volume.channel .. ": " .. args[1] .. "% ")
	widget:set_color (volume.colors.unmute)
	return args[1]
end, 5, volume.channel) -- relatively high update time, use of keys/mouse will force update