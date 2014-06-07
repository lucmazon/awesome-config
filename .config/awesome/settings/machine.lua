machine = {}

basedir =  os.getenv("HOME") .. "/.config/awesome/"
filename = basedir .. "local.properties"
if not utils.file_exists(filename) then
    filename = basedir .. "default.properties"
end

machine.property = {}

file = assert(io.open(filename, 'r'))

for line in file:lines() do
    key, value = string.match(line, "(.-)%s=%s(.-)$")
    machine.property[key] = value
end

machine.machine = machine.property["machine"]
machine.suffix = "-" .. machine.machine

return machine