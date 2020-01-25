## 5.2.1 2020-01-11

This release contains keyword fixes reported by Ruby 2.7.



[Compare v5.2.0...v5.2.1](https://github.com/rom-rb/rom/compare/v5.2.0...v5.2.1)

## 5.2.0 2020-01-11

Yanked and republished as 5.2.1



[Compare v5.1.2...v5.2.0](https://github.com/rom-rb/rom/compare/v5.1.2...v5.2.0)

## 5.1.2 2019-08-17


### Fixed

- [rom-core] Filtering out duplicated combine nodes works correctly with aliased nodes (@solnic)
- [rom-core] Filtering out duplicated combine nodes should no longer cause performance issues (@solnic)
- [rom-core] Relation names are properly equalized now (@solnic)
- [rom-core] Inferring class name for auto-structs works correctly with `:statuses` and `:aliases` relation names (@solnic)

### Changed

- [rom] Dependency on `rom-core` was bumped to `>= 5.1.2` (@solnic)
- [rom-changeset] Dependency on `rom-core` was bumped to `>= 5.1.2` (@solnic)
- [rom-repository] Dependency on `rom-core` was bumped to `>= 5.1.2` (@solnic)

[Compare v5.1.1...v5.1.2](https://github.com/rom-rb/rom/compare/v5.1.1...v5.1.2)

## 5.1.1 2019-08-06


### Changed

- [rom-core] Loading the gem no longer crashes in the absence of `rom` gem (issue #560) (@solnic)
- [rom] Dependency on `rom-core` was bumped to `>= 5.1.1` (@solnic)
- [rom-changeset] Dependency on `rom-core` was bumped to `>= 5.1.1` (@solnic)
- [rom-repository] Dependency on `rom-core` was bumped to `>= 5.1.1` (@solnic)

[Compare v5.1.0...v5.1.1](https://github.com/rom-rb/rom/compare/v5.1.0...v5.1.1)

## 5.1.0 2019-07-30


### Added

- [rom-core] `ROM::Transformer.map` shortcut for defining transformations (@solnic)
- [rom-core] `ROM::Transformer` supports instance methods as mapping functions now (@solnic)
- [rom-core] `ROM::Transformer` configuration can be now inlined ie `relation :users, as: :json_serializer` (@solnic)
- [rom-changeset] Plugin API :tada: (@solnic)
- [rom-changeset] Support for `command_options` in changesets for providing any additional command options (@solnic)
- [rom-changeset] Support for `command_plugins` in changesets for enabling command plugins and configuring them (@solnic)
- [rom-repository] Plugin API :tada: (@flash-gordon)

### Fixed

- [rom-core] Combining same relation multiple times no longer crashes auto-mapping (fixes #547) (@solnic)
- [rom-core] `ROM::Transformer` works correctly with inheritance (@solnic)
- [rom-core] `CommandCompiler` supports command options correctly now (@solnic)

### Changed

- [rom-core] Plugin API has been generalized to enable arbitrary component plugins (@flash-gordon)

[Compare v5.0.2...v5.1.0](https://github.com/rom-rb/rom/compare/v5.0.2...v5.1.0)

## 5.0.2 2019-05-01


### Fixed

- [rom-core] Forwarding to `root` in `Relation::Combined` behaves as expected when another combined relation was returned from the root (issue #525) (solnic)
- [rom-core] Specifying attribute options as the third argument in `attribute` DSL works again (issue #540) (solnic)

### Changed

- [rom] Dependency on `rom-core` was bumped to `~> 5.0`, `>= 5.0.2` (solnic)
- [rom] Dependency on `rom-changeset` was bumped to `~> 5.0`, `>= 5.0.1` (solnic)
- [rom-changeset] `Relation::Combined#changeset` will raise a meaningful `NotImplementedError` now (solnic)
- [rom-changeset] Passing an array to `Changeset#associate` will raise a meaningful `NotImplementedError` now (solnic)

[Compare v5.0.1...v5.0.2](https://github.com/rom-rb/rom/compare/v5.0.1...v5.0.2)

## 5.0.1 2019-04-24


### Fixed

- [rom-core] Missing dependency on `transproc` was added (solnic)

### Changed

- [rom] Dependency on `rom-core` was bumped to `~> 5.0`, `>= 5.0.1` (solnic)

[Compare v5.0.0...v5.0.1](https://github.com/rom-rb/rom/compare/v5.0.0...v5.0.1)

## 5.0.0 2019-04-24


### Changed

- `rom-core` bumped to `5.0.0` (solnic)
- `rom-changeset` bumped to `5.0.0` (solnic)
- `rom-repository` bumped to `5.0.0` (solnic)
- `rom-mapper` was moved to `core` under `rom/mapper` so it's no longer a runtime dependency (solnic)
- [rom-core] [BREAKING] `Types::Int` is now `Types::Integer` (flash-gordon)
- [rom-core] [BREAKING] Attribute aliases are no longer stored in attribute's type meta (waiting-for-dev)
- [rom-core] Updated to work with `dry-types 1.0.0` (flash-gordon)
- [rom-core] Updated to work with `dry-struct 1.0.0` (flash-gordon)
- [rom-core] Updated to work with `dry-initializer 3.0.0` (solnic)
- [rom-repository] [BREAKING] Support for ruby <= `2.4` was dropped (flash-gordon)
- [rom-repository] [BREAKING] `Repository::Root#aggregate` was removed in favor of `Relation#combine` (v-kolesnikov)

[Compare v4.2.1...v5.0.0](https://github.com/rom-rb/rom/compare/v4.2.1...v5.0.0)

## 4.2.1 2018-05-03


### Changed

- `rom-core` updated to `['~> 4.2', '>= 4.2.1']`

[Compare v4.2.0...v4.2.1](https://github.com/rom-rb/rom/compare/v4.2.0...v4.2.1)

## 4.2.0 2018-03-29


### Changed

- [rom] `rom-core` updated to `['~> 4.2', '>= 4.2.0']`
- [rom] `rom-changeset` updated to `['~> 1.0', '>= 1.0.2']`

[Compare v4.1.3...v4.2.0](https://github.com/rom-rb/rom/compare/v4.1.3...v4.2.0)

## 4.1.3 2018-02-03


### Changed

- [rom] `rom-core` updated to `['~> 4.1', '>= 4.1.3']`

[Compare v4.1.2...v4.1.3](https://github.com/rom-rb/rom/compare/v4.1.2...v4.1.3)

## 4.1.2 2018-01-15


### Changed

- [rom] `rom-core` updated to `['~> 4.1', '>= 4.1.1']`

[Compare v4.1.1...v4.1.2](https://github.com/rom-rb/rom/compare/v4.1.1...v4.1.2)

## 4.1.1 2017-12-01


### Changed

- [rom] `rom-repository` updated to `['~> 2.0', '>= 2.0.2']`

[Compare v4.1.0...v4.1.1](https://github.com/rom-rb/rom/compare/v4.1.0...v4.1.1)

## 4.1.0 2017-11-17


### Changed

- [rom] `rom-core` updated to `['~> 4.1']`
- [rom] `rom-mapper` updated to `'~> 1.1'`

[Compare v4.0.3...v4.1.0](https://github.com/rom-rb/rom/compare/v4.0.3...v4.1.0)

## 4.0.3 2017-11-14


### Changed

- [rom] `rom-core` updated to `['~> 4.0', '>= 4.0.3']`

[Compare v4.0.2...v4.0.3](https://github.com/rom-rb/rom/compare/v4.0.2...v4.0.3)

## 4.0.2 2017-11-02


### Changed

- [rom] `rom-core` updated to `['~> 4.0', '>= 4.0.2']`
- [rom] `rom-mapper` updated to `['~> 1.0', '>= 1.0.2']`
- [rom] `rom-changeset` updated to `['~> 1.0', '>= 1.0.1']`
- [rom] `rom-repository` updated to `['~> 2.0', '>= 2.0.1']`

[Compare v4.0.1...v4.0.2](https://github.com/rom-rb/rom/compare/v4.0.1...v4.0.2)

## 4.0.1 2017-10-22


### Changed

- [rom] `rom-core` updated to `['~> 4.0', '>= 4.0.1']`
- [rom] `rom-mapper` updated to `['~> 1.0', '>= 1.0.1']`

[Compare v4.0.0...v4.0.1](https://github.com/rom-rb/rom/compare/v4.0.0...v4.0.1)

## 4.0.0 2017-10-18

This release turns `rom` gem into a meta gem which depends on `rom-core`, `rom-mapper`, `rom-repository` and `rom-changeset'`. See [CHANGELOG](https://github.com/rom-rb/rom/blob/master/core/CHANGELOG.md#v400-2017-10-18) in core for more information.
