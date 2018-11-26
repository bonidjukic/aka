--[[

module:  aka
context: Module containing the tool's core logic

]]

---------------------------------------------------------------------

local _M = {}

---------------------------------------------------------------------

-- Attempts to load .aka configuration file from the current working
-- directory and if successfull returns that configuration as table
--
-- Return nil if unable to load configuration file
--
_M.get_cfg = function()
    local cfg = {}
    local f, err = loadfile('.aka', 't', cfg)

    if f then f() else print(err) end

    return cfg
end

-- Returns the alias specified by the command line argument if there is
-- a match with the configuration file entries.
--
-- Returns nil if unable to find matched alias.
--
_M.get_cmd = function(cfg, args, i)
    if not i then i = 1 end
    local val = cfg[args[i]]

    if val then
        if type(val) == 'table' then
            return _M.get_cmd(val, args, i + 1)
        end
    end

    return val
end

---------------------------------------------------------------------

return _M
