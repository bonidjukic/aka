--[[

  tests core related functions from the aka library

]]

---------------------------------------------------------------------

require 'busted.runner'()

local core = require 'aka.core'

---------------------------------------------------------------------

-- get_available_opts
--
describe('tests get_available_opts', function()
  local opts = core.get_available_opts()

  it('tests help and list', function()
    assert.is_true(type(opts) == 'table')

    assert.is_true(type(opts['help']['flags']) == 'table')
    assert.are.equal(opts['help']['flags'][1], '-h')
    assert.are.equal(opts['help']['flags'][2], '--help')

    assert.is_true(type(opts['list']['flags']) == 'table')
    assert.are.equal(opts['list']['flags'][1], '-l')
    assert.are.equal(opts['list']['flags'][2], '--list')
  end)
end)

-- get_opt
--
describe('tests get_opt', function()
  it('get opt', function()
    assert.are.equal(core.get_opt({'foo', 'bar'}), nil)
    assert.are.equal(core.get_opt({'-h', 'foo'}), nil)
    assert.are.equal(core.get_opt({'--help', 'foo', 'bar'}), nil)
    assert.are.equal(core.get_opt({'foo', '-l', 'bar'}), nil)
    assert.are.equal(core.get_opt({'foo', 'bar', '--list'}), nil)

    assert.are.equal(core.get_opt({'-h'}), 'help')
    assert.are.equal(core.get_opt({'--help'}), 'help')
    assert.are.equal(core.get_opt({'-l'}), 'list')
    assert.are.equal(core.get_opt({'--list'}), 'list')
  end)
end)

-- get_cmd
--
describe('tests get_cmd', function()
  local special_chars = '¤¶§!"#$%&\'()*+,-./0123456789:;<=>?@[\\]^_`{Çüéâ¹¸' ..
                        'äàåçêëèïîìæÆôöòûùÿ¢£¥PƒáíCóúñÑºµ¿¬½¼¡«»¦ßµ±°•·²€„…' ..
                        '†‡ˆ‰Š‹Œ‘’“”–—˜™š›œŸ¨C©®¯³´¸¹¾ÀÁÂÃÄÅÈÉÊËÌÍÎÏÐÒÓÔÕÖ×' ..
                        'ØÙÚÛÜÝÞãðõ÷øüý£¥€6§¨©ª«¬®¯°7²³´¶'

  local cfg  = {
    alias_1 = 'alias_1',
    alias_2 = {
      alias_3 = 'alias_3',
      alias_4 = {
        alias_5 = 'alias_5'
      }
    },
    alias_6 = special_chars
  }

  it('test get_cmd', function()
    assert.are.equal(
      core.get_cmd(cfg, {'alias_1'}), 'alias_1')
    assert.are.equal(
      core.get_cmd(cfg, {'alias_2', 'alias_3'}), 'alias_3')
    assert.are.equal(
      core.get_cmd(cfg, {'alias_2', 'alias_4', 'alias_5'}), 'alias_5')
    assert.are.equal(
      core.get_cmd(cfg, {'alias_6'}), special_chars)
    assert.are.equal(
      core.get_cmd(cfg, {'alias_1', 'arg_1'}), 'alias_1 arg_1')
    assert.are.equal(
      core.get_cmd(cfg, {'alias_1', 'arg_1', 'arg_2'}), 'alias_1 arg_1 arg_2')
    assert.are.equal(
      core.get_cmd(cfg, {'alias_2', 'alias_3', 'arg_1'}), 'alias_3 arg_1')
    assert.are.equal(
      core.get_cmd(cfg, {'alias_2', 'arg_1', }), nil)
    assert.are.equal(
      core.get_cmd(cfg, {'alias_2', 'alias_4', 'arg_1', 'arg_2' }), nil)
    assert.are.equal(
      core.get_cmd(
        cfg, {'alias_2', 'alias_4', 'alias_5', 'arg_1' }
      ), 'alias_5 arg_1')
    assert.are.equal(
      core.get_cmd(
        cfg, {'alias_2', 'alias_4', 'alias_5', 'arg_1', 'arg_2' }
      ), 'alias_5 arg_1 arg_2')
  end)
end)

-- get_help_str
--
describe('tests get_help_str', function()
  local s = core.get_help_str()
  local str_match = string.match

  it('tests generation of the help str', function()
    assert.is_true(type(s) == 'string')
    assert.is_not_nil(str_match(s, 'aka...per directory shell aliases'))
    assert.is_not_nil(str_match(s, 'Usage'))
    assert.is_not_nil(str_match(s, 'Options'))
    assert.is_not_nil(str_match(s, 'aka alias..sub_alias sub_sub_alias ...]'))
    assert.is_not_nil(str_match(s, '-h.--help'))
    assert.is_not_nil(str_match(s, '-l.--list'))
    assert.is_not_nil(str_match(s, '-v.--version'))
  end)
end)
