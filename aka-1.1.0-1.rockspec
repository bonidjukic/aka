package = 'aka'
version = '1.1.0-1'
source = {
  url = 'https://github.com/bonidjukic/aka/archive/v1.1.0.tar.gz',
  dir = 'aka-1.1.0',
}
description = {
  summary = 'Per directory shell aliases',
  detailed = [[
    aka is a simple command-line tool which lets
    you define per directory config files as aliases
    for shell commands.
  ]],
  homepage = 'https://github.com/bonidjukic/aka',
  license = 'GPL-3.0'
}
dependencies = {
  'lua >= 5.2'
}
build = {
  type = 'builtin',
  modules = {
    ['aka.core']  = 'aka/core.lua',
    ['aka.utils'] = 'aka/utils.lua',
    ['aka.init']  = 'aka/init.lua',
  },
  install = {
    bin = {
      aka = 'bin/aka'
    }
  }
}
