# v0.3.2 to-be-released

Fixed syntax errors when using reserved Ruby keywords as ROM::Struct attributes (flash-gordon)

[Compare v0.3.1...v0.3.2](https://github.com/rom-rb/rom-repository/compare/v0.3.1...v0.3.2)

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
