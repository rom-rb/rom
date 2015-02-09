## v0.6.0 to-be-released

### Added

* It is now possible to define custom relation, mapper and command classes during setup (solnic)
* Commands are now composable via `>>` operator (solnic)
* `Reader#one` and `Reader#one!` which can be used to retrieve one object from a relation (aflatter)
* Relation `base_name` is inferred from the class name by default (gotar)
* Relation can be registered under a custom name via `register_as` option (mcls)
* Env#read supports mapping with a specific mapper via `map` (solnic)
* Env#read yields a reader for a specific relation if block is provided (solnic)
* Adapters can use helper modules for datasets: `ArrayDataset` and `EnumerableDataset` (solnic)
* Adapter interface can now be tested via a lint test (elskwid + solnic + splattael)
* `to_ary` alias in `Reader` which addresses issue #80 (solnic)
* `tuple_count` interface in AbstractCommand which can be overridden by adapter (solnic)

### Changed

* [BREAKING] Command API was simplified - commands should be accessed directly in `.try` block (solnic)
* Schema DSL was **removed** - attributes can be specified only in mapper DSL
  and default repository can be changed when defining a relation (solnic)
* `.setup` interface requires either an adapter identifier or can accept a repository
  instance (aflatter)
* Adapter interface no longer requires specific constructor to be defined (aflatter)
* Adapters no longer need to handle connection URIs (aflatter)
* Adapter/Repository has been collapsed to *just* `Repository` (solnic)
* Relation no longer needs a header object and only operates on an adapters dataset (solnic)
* Adapter's dataset no longer require header (solnic)
* Make storage in memory adapter thread-safe #110 (splattael)
* An Adapter can provide its own Relation subclass with custom behavior (solnic)

[Compare v0.5.0...master](https://github.com/rom-rb/rom/compare/v0.5.0...master)

## v0.5.0 2014-12-31

### Added

* Mapper DSL supports `embedded` interface for nested tuples (solnic)
* Support for nested `group` mapping (solnic)
* Support for nested `wrap` mapping (solnic)
* Support for primitive type coercions (:to_string, :to_integer etc.) (solnic)
* Support for top-level `:prefix` option in mapping DSL (solnic)
* Support for top-level `:symbolize_keys` option in mapping DSL (solnic)
* Support for `:prefix` option in wrap/group mapping DSL (solnic)
* Interface for registering data mapping processors (solnic)
* Remaining relations are automatically setup from the schema (solnic)
* Each relation has now access to other relations (previously they only had
  access to raw datasets) (solnic)
* `ROM.setup` supports passing in *just an uri* which will setup a default repository (solnic)
* `ROM.setup` supports passing in conventional database connection hash (solnic)
* Adapters support extra options in addition to the base connection URI (solnic)

### Changed

* Mapping backend replaced by integration with transproc (solnic)
* Readers no longer expose adapter query DSL (solnic)
* Registry objects raise `ROM::Registry::ElementNotFoundError` when missing
  element is referenced (rather than raw KeyError) (solnic)
* Performance improvements in Reader (solnic)
* `ROM::RA` was merged into in-memory adapter as this fits there perfectly (solnic)
* It is no longer needed to explicitly execute a delete command in try block (solnic)

### Fixed

* Wrap/group skips empty tuples now (solnic)
* Readers raise a meaningful error when relation is missing (solnic)

## Internal

* Massive code clean-up and rubocop integration (chastell)
* Refactored `Reader` and mapper-specific logic into `MapperRegistry` (solnic)

[Compare v0.4.2...v0.5.0](https://github.com/rom-rb/rom/compare/v0.4.2...v0.5.0)

## v0.4.2 2014-12-19

### Added

* Mappers support tuple transformation using wrap and group operations (solnic)
* PORO model builder supports namespaced constants via `name: 'MyApp:Entities::User` (solnic)

### Changed

* `ROM::RA` interface is no longer mixed into relations by default (solnic)
* ~2.5 x speed up in aggregate mapping (solnic)
* PORO model builder only defines attribute readers now (no writers!) (solnic)
* Registry objects in Env will now raise `KeyError` when unknown name is referenced (solnic)

[Compare v0.4.1...v0.4.2](https://github.com/rom-rb/rom/compare/v0.4.1...v0.4.2)

## v0.4.1 2014-12-15

### Added

* Adapter can now implement `Adapter#dataset(name, header)` to return a dataset (solnic)
* For multi-step setup the DSL is available in `ROM` too (solnic)
* Global environment can be stored via `ROM.finalize` and accessible via `ROM.env` (solnic)
* Mapper won't infer attributes from the header if `:inherit_header` option is set to false (solnic)

### Changed

* Schema can be defined in multiple steps (solnic)
* Setting model in mapper DSL is no longer required and defaults to `Hash` (solnic)
* Adapter datasets no longer have to return headers when they are provided by schema (solnic)

[Compare v0.4.0...v0.4.1](https://github.com/rom-rb/rom/compare/v0.4.0...v0.4.1)

## v0.4.0 2014-12-06

### Added

* Command API (solnic)
* Setup DSL is now available within the `ROM.setup` block (solnic)
* Support for setting up a logger for an adapter (solnic)
* New `Adapter#dataset?(name)` which every adapter must implement (solnic)

### Fixed

* method-missing in `Repository` and `Env` kindly calls `super` (solnic)

### Changed

* Abstract `Adapter` defines `:connection` reader so it doesn't have to be
  defined in adapter descendants (solnic)

[Compare v0.3.1...v0.4.0](https://github.com/rom-rb/rom/compare/v0.3.1...v0.4.0)

## v0.3.1 2014-11-25

### Added

* attributes for `group` mapping operation can be specified without options (solnic)
* attributes for `wrap` mapping operation can be specified without options (solnic)
* `Env` uses Equalizer (solnic)
* boot dsl methods return self (solnic)

### Fixed

* when schema is missing booting will gracefuly skip building relations and mappers (solnic)
* in-memory join handles one-to-many and many-to-one correctly (solnic)

[Compare v0.3.0...v0.3.1](https://github.com/rom-rb/rom/compare/v0.3.0...v0.3.1)

## v0.3.0 2014-11-24

This version is a rewrite that introduces a new, simplified architecture based
on a new adapter interface.

[Compare v0.2.0...v0.3.0](https://github.com/rom-rb/rom/compare/v0.2.0...v0.3.0)

## v0.2.0 2014-04-06

### Added

* [feature] added :rename option to schema attribute DSL (solnic)
* [feature] added support for join, group, wrap, project and rename operations (solnic)
* [feature] added support for setting domain object loading strategy (solnic)
* [feature] Environment.setup can be used with a block to define schema and mapping (solnic)
* [feature] added public interface for building mappers (see Mapper.build) (solnic)
* [feature] added support for mapping embedded objects using wrap/group (solnic)
* [feature] environment exposes mapper registry via Environment#mappers (solnic)

### Changed

* [BREAKING] rom-relation, rom-mapper and rom-session were merged into rom project (solnic)
* [BREAKING] changed mapping DSL (users do...end => relation(:users) do...end) (solnic)
* [BREAKING] added :from option to mapping DSL which replaced :to (solnic)
* [internal] mappers are now backed by [morpher](https://github.com/mbj/morpher) (solnic)
* [internal] renaming and optimizing relations happens on the schema level now (solnic)
* [internal] environment will raise if unknown relation is referenced via `Environment#[]` (solnic)

[Compare v0.1.2...v0.2.0](https://github.com/rom-rb/rom/compare/v0.1.2...v0.2.0)

## v0.1.2 2013-09-02

* [updated] [rom-relation](https://github.com/rom-rb/rom-relation/blob/v0.1.2/Changelog.md#v012-2013-09-02)

[Compare v0.1.1...v0.1.2](https://github.com/rom-rb/rom/compare/v0.1.1...v0.1.2)

## v0.1.1 2013-08-30

* [updated] [rom-relation](https://github.com/rom-rb/rom-relation/blob/v0.1.1/Changelog.md#v011-2013-08-30)
* [updated] [rom-session](https://github.com/rom-rb/rom-session/blob/v0.1.1/Changelog.md#v011-2013-08-30)

[Compare v0.1.0...v0.1.1](https://github.com/rom-rb/rom/compare/v0.1.0...v0.1.1)

## v0.1.0 2013-08-23

First public release
