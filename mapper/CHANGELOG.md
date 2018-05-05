# 1.2.1 2018-05-03

* `dry-types` dependency is constrained with `~> 0.12.1`

# 1.2.0 2018-03-29

## Added

* Custom `MapperCompiler` subclass can provide mapper options via `mapper_options(...)` class attribute (solnic)

# 1.1.0 2017-11-17

### Fixed

* Aliased attributes are handled correctly by mapper compiler (solnic)

### Changed

* Mapper compiler no longer handles wrapped attributes in an SQL-specific way (solnic)

# 1.0.2 2017-11-02

### Fixed

* Missing dependency on `dry-struct` was added (solnic)

# 1.0.1 2017-10-22

### Added

* Support for inferred enum schema attributes (solnic)

[Compare v4.0.0..v4.0.1](https://github.com/rom-rb/rom-mapper/compare/v4.0.0...v4.0.1)

# 1.0.0 2017-10-18

### Added

* New mapper type - `ROM::Transformer`, which exposes [transproc](https://github.com/solnic/transproc)'s DSL (solnic)

# 0.5.1 2017-05-04

### Changed

* The `dry-core` dependency has been relaxed (flash-gordon)

[Compare v0.5.0..v0.5.1](https://github.com/rom-rb/rom-mapper/compare/v0.5.0...v0.5.1)

# 0.5.0 2017-01-29

### Changed

* Drop rom-support dependency in favor of dry-core (flash-gordon)

[Compare v0.4.0..v0.5.0](https://github.com/rom-rb/rom-mapper/compare/v0.4.0...v0.5.0)

# v0.4.0 2016-07-27

### Changed

* Raise a meaningful exception if no coercer exists (astupka)
* Don’t reject keys if copy_keys option is true (astupka)

[Compare v0.3.0..v0.4.0](https://github.com/rom-rb/rom-mapper/compare/v0.3.0...v0.4.0)

# v0.3.0 2016-01-06

### Added

* Allow `attribute`'s `:from` option to take an array of other attribute names (hmadison)

### Changed

* Coercer blocks are now executed in the context of the mapper object (AMHOL)

### Fixed

* `model` will skip excluded attributes (chastell)

[Compare v0.2.0..v0.3.0](https://github.com/rom-rb/rom-mapper/compare/v0.2.0...v0.3.0)

# v0.2.0 2015-08-10

Import code from rom 0.8.1

[Compare v0.1.1..v0.2.0](https://github.com/rom-rb/rom-mapper/compare/v0.1.0...v0.2.0)

# v0.1.1 2013-09-02

* [internal] Moved version file to rom/mapper/version (solnic)

[Compare v0.1.0..v0.1.1](https://github.com/rom-rb/rom-mapper/compare/v0.1.0...v0.1.1)

# v0.1.0 2013-08-23

First public release
