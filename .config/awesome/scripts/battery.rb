#!/usr/bin/env ruby
battery = ` upower -i $(upower -e | grep 'BAT') | grep -E "state|to\ full|percentage"`
split = battery.split(' ')
state = split[1]

if (state == "charging")
  percentage = split[8]
else
  percentage = split[3]
end

if (state == 'discharging')
  puts "<span color=\"red\">#{percentage}</span>"
else
  puts "<span color=\"green\">#{percentage}</span>"
end
