--[[

aka - Per directory shell aliases

]]

---------------------------------------------------------------------

local os     = os
local strfmt = string.format

---------------------------------------------------------------------

local aka = {}

local mt = {
  __call = function(self, args)
    self:init(args)
  end
}

setmetatable(aka, mt)

---------------------------------------------------------------------

-- Initializes aka library which sets some objects on the instance
-- and calls parsing function if the config file has been found
--
function aka:init(args)
  self.args = args
  self.cfg  = aka.get_cfg()
  self.opt  = aka.get_opt(self.args)
  self.cmd  = aka.get_cmd(self.cfg, self.args)

  if #self.args == 0 then
    aka.print_help()     -- single argument is invalid choice, print help
  elseif self.opt then
    self.run_opt(self.opt) -- run option function
  else
    self.run_cmd(self.cmd) -- run alias(es) command
  end
end

-- Returns all available CLI options
--
function aka.get_available_opts()
  return { help = {'-h', '--help'},
           list = {'-l', '--list'}, }
end

-- Returns CLI option which matches one of the available options defined
-- in aka.get_available_opts function
--
function aka.get_opt(args)
  if #args == 1 then -- option can only be a single argument
    for opt_label, opts in pairs(aka.get_available_opts()) do
      for _, opt in pairs(opts) do
        if opt == args[1] then return opt_label end
      end
    end
  end

  return
end

-- Calls aka module function with the following name: `run_{opt_name}_opt`
--
function aka.run_opt(opt)
  aka['run_' .. opt .. '_opt']()
end

-- Prints help message
--
function aka.run_help_opt()
  aka.print_help()
end

-- Prints all available aliases found in the configuration file
--
function aka.run_list_opt()
  print 'TODO list all aliases'
end

-- Returns the alias specified by the command line argument if there is
-- a match with the configuration file entries.
--
-- Returns nil if unable to find matched alias.
--
function aka.get_cmd(cfg, args, idx)
  if not idx then idx = 1 end
  local val = cfg[args[idx]]

  if val then
    if type(val) == 'table' then
      return aka.get_cmd(val, args, idx + 1)
    end
  end

  -- Verify that number of arguments match
  return (idx == #args) and val or nil
end

-- Runs command alias or prints error if the alias could not be found
--
function aka.run_cmd(cmd)
  if not cmd then
    aka.print_err('alias not found in the .aka config file.')
    os.exit()
  else
    os.execute(cmd)
  end

  return
end

-- Attempts to load .aka configuration file from the current working
-- directory and if successfull returns that configuration as table
--
-- Return nil if unable to load configuration file
--
function aka.get_cfg()
  local cfg = {}
  local f, err = loadfile('.aka', 't', cfg)

  if f then
    f()
    return cfg
  else
    aka.print_err('.aka config file not found.')
    os.exit()
  end
end

-- Prints error message
--
function aka.print_err(err)
  print(strfmt('aka: %s\nSee \'aka -h\' or \'aka --help\'', err))
end

-- Prints usage message
--
function aka.print_help()
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

-- Bootstrap part of the library which simply calls aka (meta)table
-- with the command line arguments table `arg`
aka(arg)
