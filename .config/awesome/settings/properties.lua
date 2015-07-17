properties = {}

basedir =  os.getenv("HOME") .. "/.config/awesome/"
filename = basedir .. "local.properties"
if not utils.file_exists(filename) then
    filename = basedir .. "default.properties"
end

buffer = {}

file = assert(io.open(filename, 'r'))

for line in file:lines() do
    key, value = string.match(line, "(.-)%s=%s(.-)$")
    buffer[key] = value
end

properties.machine = buffer["machine"]
properties.main_screen = buffer["main_screen"]

return properties
