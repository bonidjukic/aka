--[[

  aka - Per directory shell aliases

]]

---------------------------------------------------------------------

local aka   = require 'aka.core'
local utils = require 'aka.utils'

---------------------------------------------------------------------

local args       = arg
local os_execute = os.execute

---------------------------------------------------------------------

-- Attempt to retrieve a CLI argument option
local opt = aka.get_opt(args)

-- If we have a single argument, or a `help` option -> print help message
if #args == 0 or (opt and opt == 'help') then aka.run_help_opt() return end

-- Load configuration

local cfg, err = utils.load_cfg(aka.CFG_FILE)
if err then aka.print_err(err) return end

-- Run option runner function if we have an argument option
if opt then aka.run_opt { opt = opt, config = cfg} return end

-- Run alias command if it exists
local cmd = aka.get_cmd(cfg, args)
if cmd then os_execute(cmd)
else aka.print_err('alias not found within the .aka config file') end
