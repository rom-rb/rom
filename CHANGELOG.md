# 5.0.0 to-be-released

* All version numbers have been inlined to `5.0.0`
* `rom-mapper` gem has been retired and `ROM::Mapper` is now part of `rom-core`

## rom

* `rom-core` bumped to `5.0.0` (solnic)
* `rom-changeset` bumped to `5.0.0` (solnic)
* `rom-repository` bumped to `5.0.0` (solnic)
* `rom-mapper` was moved to `core` under `rom/mapper` so it's no longer a runtime dependency (solnic)

## rom-core

* [BREAKING] `Types::Int` is now `Types::Integer` (flash-gordon)
* [BREAKING] Attribute aliases are no longer stored in attribute's type meta (waiting-for-dev)
* Updated to work with `dry-types 1.0.0` (flash-gordon)
* Updated to work with `dry-struct 1.0.0` (flash-gordon)
* Updated to work with `dry-initializer 3.0.0` (solnic)

## rom-repository

* [BREAKING] Support for ruby <= `2.4` was dropped (flash-gordon)
* [BREAKING] `Repository::Root#aggregate` was removed in favor of `Relation#combine` (v-kolesnikov)

## rom-changeset

*No changes*

[Compare v4.2.1...master](https://github.com/rom-rb/rom/compare/v4.2.1...master)

# 4.2.1 2018-05-03

* `rom-core` updated to `['~> 4.2', '>= 4.2.1']`

[Compare v4.2.0...v4.2.1](https://github.com/rom-rb/rom/compare/v4.2.0...v4.2.1)

# 4.2.0 2018-03-29

* `rom-core` updated to `['~> 4.2', '>= 4.2.0']`
* `rom-changeset` updated to `['~> 1.0', '>= 1.0.2']`

[Compare v4.1.3...v4.2.0](https://github.com/rom-rb/rom/compare/v4.1.3...v4.2.0)

# 4.1.3 2018-02-03

* `rom-core` updated to `['~> 4.1', '>= 4.1.3']`

[Compare v4.1.2...v4.2.0](https://github.com/rom-rb/rom/compare/v4.1.2...v4.1.3)

# 4.1.2 2018-01-15

* `rom-core` updated to `['~> 4.1', '>= 4.1.1']`

[Compare v4.1.1...v4.1.2](https://github.com/rom-rb/rom/compare/v4.1.1...v4.1.2)

# 4.1.1 2017-12-01

* `rom-repository` updated to `['~> 2.0', '>= 2.0.2']`

[Compare v4.1.0...v4.1.1](https://github.com/rom-rb/rom/compare/v4.1.0...v4.1.1)

# 4.1.0 2017-11-17

* `rom-core` updated to `['~> 4.1']`
* `rom-mapper` updated to `'~> 1.1'`

[Compare v4.0.3...v4.1.0](https://github.com/rom-rb/rom/compare/v4.0.3...v4.1.0)

# 4.0.3 2017-11-14

* `rom-core` updated to `['~> 4.0', '>= 4.0.3']`

[Compare v4.0.2...v4.0.3](https://github.com/rom-rb/rom/compare/v4.0.2...v4.0.3)

# 4.0.2 2017-11-02

* `rom-core` updated to `['~> 4.0', '>= 4.0.2']`
* `rom-mapper` updated to `['~> 1.0', '>= 1.0.2']`
* `rom-changeset` updated to `['~> 1.0', '>= 1.0.1']`
* `rom-repository` updated to `['~> 2.0', '>= 2.0.1']`

[Compare v4.0.1...v4.0.2](https://github.com/rom-rb/rom/compare/v4.0.1...v4.0.2)

# 4.0.1 2017-10-22

* `rom-core` updated to `['~> 4.0', '>= 4.0.1']`
* `rom-mapper` updated to `['~> 1.0', '>= 1.0.1']`

[Compare v4.0.0..v4.0.1](https://github.com/rom-rb/rom-mapper/compare/v4.0.0...v4.0.1)

# 4.0.0 2017-10-18

This release turns `rom` gem into a meta gem which depends on `rom-core`, `rom-mapper`, `rom-repository` and `rom-changeset'`. See [CHANGELOG](https://github.com/rom-rb/rom/blob/master/core/CHANGELOG.md#v400-to-be-released) in core for more information.
