# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Add ability to view the current aka version (`-v`, `--version`)
- Generate help text dynamically (from table in `core.get_available_opts`)

## [1.3.0] - 2019-01-20
### Added
- Alias arguments functionality
- luacov support (with cluacov)
- README: Codecov version badge, alias arguments functionality

### Changed
- Switch to LuaJIT instead of pure Lua
- Improve `path_join` helper function

## [1.2.0] - 2018-12-23
### Added
- Recursive config file search functionality
- README: nomenclature section, LuaRocks version badge, list functionality

### Changed
- Switch to LuaJIT instead of pure Lua
- Improve `path_join` helper function

## [1.1.0] - 2018-12-10
### Added
- List all aliases functionality
- `core` module tests
- Travis-CI support

### Changed
- README: asciicast, badges

## [1.0.0] - 2018-12-07
### Added
- First usable version of the project

