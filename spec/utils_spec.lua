--[[

  tests utils related functions from the aka library

]]

---------------------------------------------------------------------

require 'busted.runner'()

local utils = require 'aka.utils'

---------------------------------------------------------------------

-- file_exists
--
describe('tests file_exists', function()
  local tmpf = '/tmp/aka_test_file'

  setup(function()
    f = io.open(tmpf, 'w')
    f:write('Test file')
    f:close()
  end)

  teardown(function()
    os.remove(tmpf)
  end)

  it('tmp file exists', function()
    assert.is_true(utils.file_exists(tmpf))
  end)
end)

-- pwd
--
describe('tests pwd', function()
  it('get current dir', function()
    assert.are.equal(utils.pwd(), io.popen 'pwd':read '*l')
  end)
end)

-- path_join
--
describe('tests path_join', function()
  it('zero args', function()
    assert.are.equal(utils.path_join(), '')
  end)
  it('one arg', function()
    assert.are.equal(utils.path_join('/tmp'), '/tmp')
  end)
  it('three args', function()
    assert.are.equal(utils.path_join('foo', 'bar', 'baz'), 'foo/bar/baz')
  end)
  it('six args', function()
    assert.are.equal(utils.path_join('a', '1', 'b', '2', 'c', '3'),
                     'a/1/b/2/c/3')
  end)
end)

-- load_cfg
--
describe('tests load_cfg', function()
  local tmpf = '/tmp/aka_test_file'
  local cfg  = {
    alias_1 = 'alias_1',
    alias_2 = {
      alias_3 = 'alias_3'
    }
  }

  setup(function()
    f = io.open(tmpf, 'w')
    f:write('alias_1 = "alias_1" alias_2 = { alias_3 = "alias_3" }')
    f:close()
  end)

  teardown(function()
    os.remove(tmpf)
  end)

  it('test config file', function()
    local cfgf, err = utils.load_cfg(tmpf)

    assert.is.truthy(cfgf)
    assert.are.equal(err, nil)
    assert.are.same(cfg, cfgf)
    assert.are.equal(cfg.alias_1, cfgf.alias_1)
    assert.are.same(cfg.alias_2, cfgf.alias_2)
    assert.are.equal(cfg.alias_3, cfgf.alias_3)
  end)
end)
