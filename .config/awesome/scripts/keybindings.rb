#!/usr/bin/env ruby

re = /--\s*#\s*(.*?)\s*#\s*(.*?)\s*#\s*(.*?)$/

keybindings = {}

def zenify_keybinding(keybinding, text_message)
  return "\t<b><big>#{keybinding}</big></b> : #{text_message}"
end

def zenify_title(title)
  return "<b><big><span color='red'>#{title}</span></big></b>"
end

File.open(File.join(ENV['HOME'], '.config/awesome/rc.lua')).each do |line|
  match = line.match re
  if match
    title = zenify_title(match[1])
    if not keybindings[title]
      keybindings[title] = []
    end
    keybindings[title] << zenify_keybinding(match[2], match[3])
  end
end

result = ""
keybindings.each do |key, value|
  result += "\n" + key + "\n"
  result += value.to_a * "\n"
end

puts result.strip