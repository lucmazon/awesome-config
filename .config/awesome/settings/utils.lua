utils = {}

utils.run_once = function (cmd)
    awful.util.spawn_with_shell("pgrep " .. cmd .. " > /dev/null || (" .. cmd .. " &)")
end

utils.array_concat = function (...)
    local t = {}

    for i = 1, arg.n do
        local array = arg[i]
        if (type(array) == "table") then
            for j = 1, #array do
                t[#t+1] = array[j]
            end
        else
            t[#t+1] = array
        end
    end

    return t
end

utils.file_exists = function (name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

return utils
