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

-- Attempts to load the configuration file by recursively seeking for it
-- starting with the current directory and moving up until reaching root dir
--
function _M.load_cfg(cfg_file)
  -- Define root directory
  local ROOT_DIR = '/'

  -- Recursive seek config function
  local function seek_cfg(dir)
    -- If not dir then set dir to the current working directory
    if not dir then dir = _M.getcwd() end
    -- Check if we should stop seeking for the config
    if dir == ROOT_DIR then return nil end

    -- If the config file exist this particular location, return its path
    if _M.file_exists(cfg_file) then
      return _M.path_join(_M.getcwd(), cfg_file)
    else
      -- Go up one directory and call `seek_cfg` to continue seeking
      _M.chdir('..')
      return seek_cfg()
    end
  end

  local cfg  = {}
  local path = seek_cfg()

  -- Check if we reached `ROOT_DIR` before finding the config
  if not path then
    return nil, 'config file not found'
  end

  -- Load the config chunk and execute it
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
