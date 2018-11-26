--[[

module:  main
context: Aka tool's main module which serves as a bootstrap point

]]

---------------------------------------------------------------------

local aka = require 'aka'

---------------------------------------------------------------------

local cfg = aka.get_cfg()
local cmd = aka.get_cmd(cfg, arg)

print(cmd)
