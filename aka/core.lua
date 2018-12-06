--[[

  aka - Per directory shell aliases

]]

---------------------------------------------------------------------

local str_fmt = string.format

---------------------------------------------------------------------

local _M = {}

---------------------------------------------------------------------

_M.CFG_FILE = '.aka'

---------------------------------------------------------------------

-- Returns all available CLI options
--
function _M.get_available_opts()
  return { help = {'-h', '--help'},
           list = {'-l', '--list'}, }
end

-- Returns CLI option which matches one of the available options defined
-- in `get_available_opts` function
--
function _M.get_opt(args)
  if #args == 1 then -- option can only be a single argument
    for opt_label, opts in pairs(_M.get_available_opts()) do
      for _, opt in pairs(opts) do
        if opt == args[1] then return opt_label end
      end
    end
  end

  return nil
end

-- Calls aka module function with the following name: `run_{opt_name}_opt`
--
function _M.run_opt(opt)
  _M['run_' .. opt .. '_opt']()
end

-- Prints help message
--
function _M.run_help_opt()
  return _M.print_help()
end

-- Prints all available aliases found in the configuration file
--
function _M.run_list_opt()
  print 'TODO list all aliases'
end

-- Returns the alias specified by the command line argument if there is
-- a match with the configuration file entries.
--
-- Returns nil if unable to find matched alias.
--
function _M.get_cmd(cfg, args, idx)
  if not idx then idx = 1 end
  local val = cfg[args[idx]]

  if val then
    if type(val) == 'table' then
      return _M.get_cmd(val, args, idx + 1)
    end
  end

  -- Verify that number of arguments match
  return (idx == #args) and val or nil
end

-- Prints error message to the screen
--
function _M.print_err(err)
  print(str_fmt('aka: %s\nSee \'aka -h\' or \'aka --help\'', err))
end

-- Prints usage message to the screen
--
function _M.print_help()
  print [[
aka - per directory shell aliases

Usage:
  aka alias [sub_alias sub_sub_alias ...]
  aka -h|--help
  aka -l|--list


Options:
  -l, --list        List all aliases
  -h, --help        Print usage
]]
end

---------------------------------------------------------------------

return _M
