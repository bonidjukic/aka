--[[

  aka - Per directory shell aliases

]]

---------------------------------------------------------------------

local aka   = require 'aka'
local utils = require 'utils'

---------------------------------------------------------------------

local args       = arg
local os_execute = os.execute

---------------------------------------------------------------------

-- Single argument is invalid choice, print help
if #args == 0 then aka.print_help() return end

-- Check if the first argument is an option
local opt = aka.get_opt(args)
if opt then aka.run_opt(opt) return end

-- Load configuration
local cfg_path = utils.path_join(utils.pwd(), aka.CFG_FILE)
local cfg, err = utils.load_cfg(cfg_path)
if err then aka.print_err(err) return end

-- Run alias command if it exists
local cmd = aka.get_cmd(cfg, args)
if cmd then
  os_execute(cmd)
else
  aka.print_err('alias not found within the .aka config file')
end
