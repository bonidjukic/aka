--[[

  aka - Per directory shell aliases

]]

---------------------------------------------------------------------

local utils        = require 'aka.utils'

local io_write     = io.write
local str_fmt      = string.format
local str_rep      = string.rep
local table_concat = table.concat
local table_insert = table.insert

---------------------------------------------------------------------

local _M = {}

---------------------------------------------------------------------

_M.CFG_FILE = '.aka'

---------------------------------------------------------------------

-- Returns all available CLI options
--
function _M.get_available_opts()
  return { help    = { flags = {'-h', '--help'},
                       help_text = 'List all aliases'},
           list    = { flags = {'-l', '--list'},
                       help_text = 'Print usage'},
           version = { flags = {'-v', '--version'},
                       help_text = 'Show version information'} }
end

-- Returns CLI option which matches one of the available options defined
-- in `get_available_opts` function
--
function _M.get_opt(args)
  if #args == 1 then -- option can only be a single argument
    for opt_label, opt in pairs(_M.get_available_opts()) do
      for _, flag in pairs(opt['flags']) do
        if flag == args[1] then return opt_label end
      end
    end
  end

  return nil
end

-- Calls aka module function with the following name: `run_{opt_name}_opt`
--
function _M.run_opt(t)
  return _M['run_' .. t.opt .. '_opt'](t)
end

-- Prints help message
--
function _M.run_help_opt(t)
  print(_M.get_help_str())
end

-- Prints all available aliases found in the configuration file
--
function _M.run_list_opt(t)
  local opt = t.opt
  local cfg = t.config
  local n   = 0

  print('Listing all aka aliases...\n')
  print(str_rep('-', 40))

  local list_recur = function(cfg, list_recur)
    local indent = function()
      for i = 1, n do
        io_write('    ')
      end
    end

    for k, v in pairs(cfg) do
      if type(v) == 'table' then
        indent()
        print('- [' .. k .. ']')
        n = n + 1
        list_recur(v, list_recur)
      else
        indent()
        print(str_fmt('- [%s = \'%s\']', tostring(k), tostring(v)))
      end
    end
    n = n - 1
  end

  for k, v in pairs(cfg) do
    if type(v) == 'table' then
      print('[' .. k .. ']')
      n = n + 1
      list_recur(v, list_recur)
    else
      print(str_fmt('[%s = \'%s\']', tostring(k), tostring(v)))
    end
  end

  print(str_rep('-', 40))
  print('')
end

-- Prints version information to the screen
--
function _M.run_version_opt(t)
  print(str_fmt('aka version: %s', utils.get_aka_version()))
end

-- Returns the alias specified by the command line argument if there is
-- a match with the configuration file entries.
--
-- Returns nil if unable to find a matched alias.
--
function _M.get_cmd(cfg, args, idx)
  if not idx then idx = 1 end
  local val = cfg[args[idx]]

  if val then
    if type(val) == 'table' then
      -- continue searching deeper
      return _M.get_cmd(val, args, idx + 1)
    else
      -- we found the match, let's check for input arguments
      local input_args = {}
      for i = idx + 1, #args do -- skip the arguments used for alias match
        input_args[#input_args + 1] = ' ' .. args[i]
      end
      -- Return cmd and append input arguments if they exist
      return val .. table_concat(input_args)
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

-- Returns the usage text using the definition table
-- from the `get_available_opts` function
--
function _M.get_help_str()
  local t = {
    'aka - per directory shell aliases\n\n',
    'Usage:\n',
    '  aka alias [sub_alias sub_sub_alias ...]\n\n'
  }

  for opt_label, opt in pairs(_M.get_available_opts()) do
    local flags = table_concat(opt['flags'], '|')
    table_insert(t, str_fmt('  aka %s\n', flags))
  end

  table_insert(t, '\nOptions:')

  for opt_label, opt in pairs(_M.get_available_opts()) do
    local flags = table_concat(opt['flags'], ', ')
    table_insert(t, str_fmt('\n  aka %s\t%s', flags, opt['help_text']))
  end

  return table_concat(t)
end

---------------------------------------------------------------------

return _M
