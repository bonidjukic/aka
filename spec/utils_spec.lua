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

-- chdir
--
describe('tests chdir', function()
  local cwd

  setup(function()
    cwd = utils.getcwd()
  end)

  teardown(function()
    utils.chdir(cwd)
  end)

  it('tests temporary directory', function()
    utils.chdir('/tmp')
    utils.chdir('..')
    assert.are.equal(utils.getcwd(), '/')
    utils.chdir('tmp')
    assert.are.equal(utils.getcwd(), '/tmp')
  end)
end)

-- getcwd
--
describe('tests getcwd', function()
  it('get current dir', function()
    assert.are.equal(utils.getcwd(), io.popen 'pwd':read '*l')
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
  local cwd       = utils.getcwd()
  local tmpf      = 'aka_test_file'
  local tmpf_path = utils.path_join('/tmp', tmpf)

  local cfg  = {
    alias_1 = 'alias_1',
    alias_2 = {
      alias_3 = 'alias_3'
    }
  }

  setup(function()
    utils.chdir('/tmp')
    f = io.open(tmpf_path, 'w')
    f:write('alias_1 = "alias_1" alias_2 = { alias_3 = "alias_3" }')
    f:close()
  end)

  teardown(function()
    os.remove(tmpf_path)
    utils.chdir(cwd)
  end)

  it('test config file', function()
    local cfgf, err = utils.load_cfg(tmpf)

    assert.is.truthy(cfgf)
    assert.is_nil(err)
    assert.are.same(cfg, cfgf)
    assert.are.equal(cfg.alias_1, cfgf.alias_1)
    assert.are.same(cfg.alias_2, cfgf.alias_2)
    assert.are.equal(cfg.alias_3, cfgf.alias_3)
  end)
end)

-- load_cfg recursive
--
describe('tests load_cfg recursive', function()
  local cwd            = utils.getcwd()
  local tmpf           = 'aka_test_file'
  local tmpf_root_dir  = '/tmp/aka_test'
  local tmpf_dir       = utils.path_join(tmpf_root_dir, 'a/b/c/d/e/f')
  local tmpf_path      = utils.path_join(tmpf_dir, tmpf)

  local cfg  = {
    alias_1 = 'alias_1',
    alias_2 = {
      alias_3 = 'alias_3'
    }
  }

  setup(function()
    utils.os_capture_exec('mkdir -p ' .. tmpf_dir)
    utils.chdir(tmpf_dir)

    f = io.open(tmpf_path, 'w')
    f:write('alias_1 = "alias_1" alias_2 = { alias_3 = "alias_3" }')
    f:close()
  end)

  teardown(function()
    utils.os_capture_exec('rm -r ' .. tmpf_root_dir)
    utils.chdir(cwd)
  end)

  it('test config file', function()
    local cfgf, err = utils.load_cfg(tmpf)

    assert.is.truthy(cfgf)
    assert.is_nil(err)
    assert.are.same(cfg, cfgf)
    assert.are.equal(cfg.alias_1, cfgf.alias_1)
    assert.are.same(cfg.alias_2, cfgf.alias_2)
    assert.are.equal(cfg.alias_3, cfgf.alias_3)
  end)
end)

-- load_cfg recursive - no results
--
describe('tests load_cfg recursive - no results', function()
  local cwd  = utils.getcwd()
  local tmpf = 'aka_test_fileys'

  teardown(function()
    utils.chdir(cwd)
  end)

  it('test config file', function()
    local cfgf, err = utils.load_cfg(tmpf)
    assert.is_nil(cfgf)
    assert.is.truthy(err)
  end)
end)

-- get_rockspec_filename
--
describe('tests get_rockspec_filename', function()
  it('test getting current rockspec filename', function()
    local filename = utils.get_rockspec_filename()

    assert.is.truthy(filename)
    start_idx, end_idx = string.find(filename, 'aka')
    assert.equal(start_idx, 1)
    assert.equal(end_idx, 3)

    capture = '(%a+)-(%d).(%d).(%d)-(%d).(%a+)'
    aka, maj, min, patch, spec, rockspec = string.match(filename, capture)
    assert.equal(aka, 'aka')
    assert.equal(rockspec, 'rockspec')
  end)
end)

-- get_aka_version
--
describe('tests get_aka_version', function()
  it('test getting current aka version from the rockspec file', function()
    local version = utils.get_aka_version()

    assert.is.truthy(version)

    capture = '(%d).(%d).(%d)-(%d)'
    maj, min, patch, spec = string.match(version, capture)
    assert.equal(type(tonumber(maj)), 'number')
    assert.equal(type(tonumber(min)), 'number')
    assert.equal(type(tonumber(patch)), 'number')

    rockspec_filename = utils.os_capture_exec('find *.rockspec')
    local rockspec = {}
    local chunk, err = loadfile(rockspec_filename, 't', rockspec)
    chunk()
    assert.equal(rockspec['version'], version)
  end)
end)
