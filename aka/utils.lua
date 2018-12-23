--[[

  aka - Per directory shell aliases

]]

---------------------------------------------------------------------

local ffi = require 'ffi'

ffi.cdef [[
  int  chdir(const char*);
  char *getcwd(char *buf, size_t size);
]]

local const = {
  MAX_PATH = 4096 -- UNIX
}

---------------------------------------------------------------------

local io       = io
local io_open  = io.open
local io_popen = io.popen
local io_close = io.close
local str_gsub = string.gsub

---------------------------------------------------------------------

local _M = {}

---------------------------------------------------------------------

-- Checks if file exists on a given location
--
function _M.file_exists(path)
  local f = io_open(path, 'r')
  if f ~= nil then io_close(f) return true
  else return false end
end

-- Changes the current workdig directory to the specified directory
--
function _M.chdir(dir)
  return ffi.C.chdir(dir)
end

-- Returns the current working directory
--
function _M.getcwd()
  local buf = ffi.new('char[?]', const.MAX_PATH)
  ffi.C.getcwd(buf, const.MAX_PATH)
  return ffi.string(buf)
end

-- Returns path joined with a slash character, e.g. foo/bar/baz
--
function _M.path_join(...)
  return table.concat({...}, '/')
end

-- Attempts to load configuration file from the current working
-- directory and if successfull returns the configuration as table
--
function _M.load_cfg(path)
  if not _M.file_exists(path) then
    local err = 'config file not found: ' .. path
    return nil, err
  end

  local cfg = {}

  local chunk, err = loadfile(path, 't', cfg)
  if not err then chunk() end

  return cfg, err
end

-- Executes the command and returns its captured output
-- Thanks to: https://stackoverflow.com/a/326715/6817428
--
function _M.os_capture_exec(cmd)
  local f = assert(io_popen(cmd, 'r'))
  local s = assert(f:read('*a'))

  f:close()

  s = str_gsub(s, '^%s+', '')
  s = str_gsub(s, '%s+$', '')
  s = str_gsub(s, '[\n\r]+', ' ')

  return s
end

---------------------------------------------------------------------

return _M
