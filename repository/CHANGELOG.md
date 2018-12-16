# To be released

### Changed

* [BREAKING] `Repository::Root#aggregate` was removed in favor of `Relation#combine` (v-kolesnikov)

# v2.0.2 2017-12-01

## Added

* `commands` macro supports passing options for plugins via `plugins_options` (GustavoCaso)

## Fixed

* Root repository classes are cached now, which fixes problems with superclass mismatch exceptions (solnic)

# v2.0.1 2017-11-02

## Fixed

* YARD docs for `Repository::Root` no longer mention `Repository#changeset` as it was removed in 4.0.0 (solnic)
* Correct runtime dependencies were added (solnic)

# v2.0.0 2017-10-18

### Changed

* [BREAKING] `Relation#combine` no longer works with arbitrary `many` and `one` options. Configure associations instead and use their identifiers as arguments (solnic)
* [BREAKING] `Relation#combine_parents` was removed (solnic)
* [BREAKING] `Relation#combine_children` was removed (solnic)
* [BREAKING] `Relation#wrap_parent` was removed, configure associations and use their identifiers in `wrap` instead (solnic)
* [BREAKING] `Repository#command` was removed in favor of `Relation#command` (solnic)
* [BREAKING] `Repository#changeset` was removed in favor of `Relation#changeset` (solnic)

### Internal

* `RelationProxy` was removed as its functionality was ported and improved in rom-core (solnic)

# v1.3.3 2017-05-31

### Added

* `Changeset#extend` to exclude steps from the `#diff` output, this allows
  to filter out timestamp changes prior to updates so that we can avoid
  hitting the database in case of timestamp-only changes. You still can call `.map(:touch)`
  if you want to have `updated_at` refreshed unconditionally (flash-gordon)

## Fixed

* `aggregate` and `combine` works correctly with nested graph options where associations are aliased (solnic)
* Auto-mapping no longer creates intermediate struct objects for combined relations (which caused massive performance degradation in some cases) (solnic)
* Aliased associations no longer cause mapping to intermediate structs (solnic)

[Compare v1.3.2...v1.3.3](https://github.com/rom-rb/rom-repository/compare/v1.3.2...v1.3.3)

# v1.3.2 2017-05-02

### Fixed

* Fix building changesets with relation using `Root#changeset` (flash-gordon)
* Fix wrap when aliased relation is used (solnic)
* Fix accessing `data` in map block in changesets (flash-gordon+solnic)

### Changed

* Calculate diff only with respect to keys present on the original tuple (yuszuv+solnic)

# v1.3.1 2017-03-25

### Fixed

* Support for using custom mappers inside `#node` (flash-gordon)

### Changed

* Updated `dry-initializer` (flash-gordon)

[Compare v1.3.0...v1.3.1](https://github.com/rom-rb/rom-repository/compare/v1.3.0...v1.3.1)

# v1.3.0 2017-03-07

### Added

* Support for chaining `Changeset#associate` (solnic)
* Inferring association name for `Changeset#associate` (solnic)
* Support for restricting `Update` and `Delete` changesets explicitly via `Changeset#by_pk` (solnic)

[Compare v1.2.0...v1.3.0](https://github.com/rom-rb/rom-repository/compare/v1.2.0...v1.3.0)

# v1.2.0 2017-03-01

### Fixed

* Support for `#read` in rom-sql was restored via mapping to `ROM::OpenStruct` (solnic)
* Using `#nodes` no longer executes redundant query with deeply nested aggregates (solnic)

### Changed

* Depends on rom >= 3.1.0 now as it provides `Relation::Graph#with_nodes` which is needed here (solnic)

[Compare v1.1.0...v1.2.0](https://github.com/rom-rb/rom-repository/compare/v1.1.0...v1.2.0)

# v1.1.0 2017-02-16

### Added

* Mapping to `ROM::Struct` can be disabled via `auto_struct` option (solnic)
* You can now use custom mappers along with auto-mapping via `map_with(:my_mapper, auto_map: true)` (solnic)
* `wrap` can be used along with association names ie `users.wrap(:address)` (solnic)
* `#node` relation method that can be used to adjust graph nodes produced by `aggregate` or `combine` (solnic)

## Fixed

* Structs raise nicer `NoMethodError` (flash-gordon)
* Custom model set on a node relation is respected when loading aggregates (solnic)

[Compare v1.0.2...v1.1.0](https://github.com/rom-rb/rom-repository/compare/v1.0.2...v1.1.0)

# v1.0.2 2017-02-13

### Fixed

* Structs uses read types for attributes so that they don't perform an unexpected serialization (flash-gordon)

[Compare v1.0.1...v1.0.2](https://github.com/rom-rb/rom-repository/compare/v1.0.1...v1.0.2)

# v1.0.1 2017-01-31

### Fixed

* `Changeset::Update` creates a command with restricted relation (solnic)
* `Changeset#result` will always return `:many` for arrays and `:one` for other objects (even when a custom object is used) (solnic)

[Compare v1.0.0...v1.0.1](https://github.com/rom-rb/rom-repository/compare/v1.0.0...v1.0.1)

# v1.0.0 2017-01-30

### Added

* New `Repository#transaction` API for executing operations inside a database transaction (flash-gordon+solnic)
* `aggregate` and `combine` support nested association specs, ie `combine(users: [tasks: :tags])` (beauby)
* Changesets support data as arrays too (solnic)
* Changesets support custom command types via `Changeset#with(command_type: :my_command)` (solnic)
* `Changeset::Delete` was added and is accessible via `repo.changeset(delete: some_relation.by_pk(1))` (solnic)
* Ability to define custom changeset classes that can be instantiated via `repo.changeset(MyChangesetClass[:rel_name]).data(some_data)` or `root_repo.changeset(MyChangesetClass)` where `MyChangesetClass` inherits from a core changeset class (solnic)
* `Changeset.map` which accepts a block and exposes a DSL for data transformations (all [transproc hash methods](https://github.com/solnic/transproc)) are available (solnic)
* `Changeset.map` which accepts a custom block that can transform data (executed in the context of a changeset object) (solnic)
* Support for composing multiple mappings via `Changeset.map` (solnic)
* `Changeset#associate` method that accepts another changeset or parent data and an association identifier, ie `post_changeset.associate(user, :author)` (solnic)
* Support for inferring typed structs based on relation schemas (solnic)
* You can now use `wrap_parent` in combined relations too (which is gazillion times faster than `combine_parents`) (solnic)

### Changed

* `ROM::Struct` is now based on `Dry::Struct` (solnic)
* rom-support dependency was removed (flash-gordon)
* `update?` and `create?` methods were removed from `Changeset:*` subclasses (solnic)

### Fixed

* `Create` commands generated for aliased associations work correctly (solnic)
* `Create` commands generated for `belongs_to` associations work correctly (solnic)
* FKs are always included in auto-generated structs used in aggregates (solnic)
* Calling undefined methods on repo relations raises a nicer error (solnic)

[Compare v0.3.1...v1.0.0](https://github.com/rom-rb/rom-repository/compare/v0.3.1...v1.0.0)

# v0.3.1 2016-07-27

Fixed gemspec so that we don't exclude all files with 'bin' in their name, geez (solnic)

[Compare v0.3.0...v0.3.1](https://github.com/rom-rb/rom-repository/compare/v0.3.0...v0.3.1)

# v0.3.0 2016-07-27

### Added

* `Repository#command` for inferring commands automatically from relations (solnic)
* `Repository.commands` macro which generates command methods (solnic)
* `Repository[rel_name]` for setting up a repository with a root relation (solnic)
* `Repository#aggregate` as a shortcut for composing relation graphs from root (solnic)
* `Repository#changeset` API for building specialized objects for handling changes in relations (solnic)

### Fixed

* Auto-mapping includes default custom mapper for a given relation (AMHOL)
* When custom mapper is set, default struct mapper won't be used (AMHOL)

### Changed

* `Relation#combine` supports passing name of configured associations for automatic relation composition (solnic)
* `Repository` constructor simply expects a rom container, which makes it work with DI libs like `dry-auto_inject` (solnic)
* Depends on `rom 2.0.0` now (solnic)
* Replace anima with `ROM::Repository::StructAttributes` (flash-gordon)

[Compare v0.2.0...v0.3.0](https://github.com/rom-rb/rom-repository/compare/v0.2.0...v0.3.0)

# v0.2.0 2016-01-06

### Added

* You can now pass a custom class that will be used for mapping using `.as(MyClass)` interface (solnic)

### Changed

* Relation plugins have been moved to `rom` and `rom-sql`. Other adapters can
  enable them too which means repository can now be used *with any adapter* (solnic)
* `Repository::Base` is deprecated, just inherit from `ROM::Repository` (solnic)

## Fixed

* Added `respond_to_missing?` to `LoadingProxy` (AMHOL)

[Compare v0.1.0...v0.2.0](https://github.com/rom-rb/rom-repository/compare/v0.1.0...v0.2.0)

# v0.1.0 2015-08-19

This release ensures that relations from different adapters can be composed
together :tada:

### Fixed

- Plugins are registered correctly for multi-env setups (AMHOL)
- multi-block `view` syntax works correctly when header is not provided as options (solnic)

[Compare v0.0.2...v0.1.0](https://github.com/rom-rb/rom-repository/compare/v0.0.2...v0.1.0)

# v0.0.2 2015-08-10

### Added

- `view` relation plugin (solnic)
- `key_inference` relation plugin (solnic)
- `base_view` sql relation plugin (solnic)
- `auto_combine` sql relation plugin (solnic)
- `auto_wrap` sql relation plugin (solnic)

### Changed

- Switched to extracted `rom-mapper` gem (solnic)

[Compare v0.0.1...v0.0.2](https://github.com/rom-rb/rom-repository/compare/v0.0.1...v0.0.2)

# v0.0.1 2015-08-05

First public release \o/

### Added

* `Relation#combine_parents` for auto-combine using eager-loading strategy aka
  relation composition (solnic)
* `Relation#combine_children` for auto-combine using eager-loading strategy aka
  relation composition (solnic)
* `Relation#wrap_parent` for auto-wrap using inner join (solnic)
* `Relation.view` for explicit relation view definitions with header and query (solnic)
* Auto-mapping feature which builds mappers that turn relations into simple structs (solnic)
