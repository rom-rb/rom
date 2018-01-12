# v4.1.1 to-be-released

## Fixed

* Changesets work with `timestamp` plugin (cflipse)

[Compare v4.1.0...v4.1.1](https://github.com/rom-rb/rom/compare/v4.1.0...v4.1.1)

# v4.1.0 2017-11-17

## Added

* Support for providing a custom mapper compiler by adapters (solnic)
* Support for aliased attributes in auto-mapping (solnic)
* Support for command plugin options, ie `use :timestamps, timestamps: %i(created_at, updated_at), datestamps: %i(:written_on)` (GustavoCaso)
* `''configuration.relations.class.ready''` event is triggered with `:adapter` filter (solnic)

## Fixed

* `'configuration.commands.class.before_build'` event is triggered with `:adapter` set, so that adapters can subscribe only to their events. This fixes a bug where an incorrect adapter would try to handle this event with a command class coming from another adapter (solnic)
* Command compiler no longer uses global temporary registry (solnic)

## Changed

* Uses `dry-inflector` now (solnic)

[Compare v4.0.2...v4.1.0](https://github.com/rom-rb/rom/compare/v4.0.2...v4.1.0)

# v4.0.2 2017-11-02

## Added

* Schemas have access to finalized relation registry (GustavoCaso + flash-gordon + solnic)

## Fixed

* Defining schema uses default attribute class correctly again (v-kolesnikov)
* Primary key name(s) are preserved when projecting schemas (flash-gordon + solnic)
* Global command cache was replaced with a local one (flash-gordon)

# v4.0.1 2017-10-22

## Internal

* `Schema#to_input_hash` uses attribute types instead of whole attribute objects (solnic)

[Compare v4.0.0...v4.0.1](https://github.com/rom-rb/rom/compare/v4.0.0...v4.0.1)

# v4.0.0 2017-10-18

Previous `rom` gem was renamed to `rom-core`

## Added

* Relations can be configured with `auto_map true` which brings auto-mapping functionality known from rom-repository (solnic)
* Relations can be configured with `auto_struct true` which brings auto-struct functionality known from rom-repository (solnic)
* `Relation#map_to(model)` which replaced `as` (solnic)
* `Relation#wrap` is now part of core API and requires associations to be configured (solnic)
* `Relation#combine` automatically returns a relation graph based on configured associations (solnic)
* `Relation#command` which automatically creates a command for a given relation, supports graphs too (solnic)
* `Relation::to_ast` which returns an AST representation of a relation. This can be used to infer other objects based on relation information (solnic)
* `Relation::Name#as` which returns an aliased relation name (solnic)
* Associations are now part of core API and available to all adapters, cross-adapter associations are supported too via `:override` option (solnic)
* New settings in association DSL:
  * `:override` option which will use configured `:view` as the relation used by association (solnic)
  * `:combine_keys` option which overriddes default combine keys that are based on join keys (solnic)
* `Schema#primary_key_name` and `Schema#primary_key_names` are now part of core schema API (solnic)
* `Schema#to_ast` which returns an AST representation of a relation schema (flash-gordon)
* Plugin system supports schema plugins (flash-gordon)
* Setup and finalization is now based on events, which you can subscribe to. This allows plugin and adapter developers to hook into components in a simple and stable way (solnic)

## Changed

* Works with MRI >= 2.3
* [BREAKING] Inferring relations from database schema **has been removed**. You need to define relations explicitly now (solnic)
* [BREAKING] Relations have `auto_map` **turned on by default**. This means that wraps and graphs return nested data structures automatically (solnic)
* [BREAKING] `Relation#combine` behavior from previous versions is now provided by `Relation#combine_with` (solnic)
* [BREAKING] `Relation#as` now returns a new relation with aliased name, use `Relation#map_with(*list-of-mapper-ids)` or `Relation#map_to(model)` if you just want to map to custom models (solnic)
* [BREAKING] `Relation.register_as(:bar)` is removed in favor of `schema(:foo, as: :bar)` (solnic)
* [BREAKING] `Relation.dataset(:foo)` is removed in favor of `schema(:foo)`. Passing a block still works like before (solnic)
* [BREAKING] `CommandRegistry#try` is removed (solnic)
* [BREAKING] `Command#with` changed behavior, use `Command#curry` instead (solnic)
* Separation between relations that are standalone or registrable in a registry is gone. All relations have names and schemas now.
  They are automatically set to defaults. In practice this means you can instantiate a relation object manually and it'll Just Work (solnic)
* Mapper and command objects are cached locally within a given rom container (solnic)

## Internal

* [BREAKING] `Relation::Curried#name` was renamed to `Relation::Curried#view` (solnic)
* [BREAKING] `Association::Name` was removed in favor of using `Relation::Name` (solnic)
* [BREAKING] `ROM::Schema::Attribute` was renamed to `ROM::Attribute` (solnic)
* Relations no longer use `method_missing` for accessing other relations from the registry (solnic)

## Fixed

* Inferred struct attributes use simplified types. This fixed a problem when read types from relation schemas would be applied twice (flash-gordon)
* Trying to register a mapper with the same identifier more than once will raise an error (GustavoCaso)
* Delegate private method calls in composite relations (flash-gordon)

# v3.2.2 2017-05-05

## Changed

* [internal] Compatibility with `dry-core` v0.3.0 (flash-gordon)

[Compare v3.2.1...v3.2.2](https://github.com/rom-rb/rom/compare/v3.2.1...v3.2.2)

# v3.2.1 2017-05-02

## Changed

* [internal] `ROM::Schema::Attribute` uses `Initializer` now (flash-gordon)

[Compare v3.2.0...v3.2.1](https://github.com/rom-rb/rom/compare/v3.2.0...v3.2.1)

# v3.2.0 2017-03-25

## Changed

* `dry-initializer` was updated to `1.3`, this is a minor change, but leads to some incompatibilities with existing adapters, hence `3.2.0` shall be released (flash-gordon)

[Compare v3.1.0...v3.2.0](https://github.com/rom-rb/rom/compare/v3.1.0...v3.2.0)

# v3.1.0 2017-03-01

## Added

* New configuration DSL for configuring plugins (solnic)
* Instrumentation plugin for relations (solnic)
* New `ROM::Relation::Loaded#empty?` method (solnic)
* New `ROM::Relation::Graph#with_nodes` which returns a new graph with new nodes (solnic)
* New `ROM::Schema#empty` which returns an empty schema (solnic)

[Compare v3.0.3...v3.1.0](https://github.com/rom-rb/rom/compare/v3.0.3...v3.1.0)

# v3.0.3 2017-02-24

## Fixed

* Curried relations when called without args while having some args filled in will return itself (solnic)

[Compare v3.0.2...v3.0.3](https://github.com/rom-rb/rom/compare/v3.0.2...v3.0.3)

# v3.0.2 2017-02-24

## Added

* `Schema::Attribute#key` which returns tuple key name, either alias or canonical name (solnic)

## Fixed

* Fix output_schema to use Attribute#key rather than canonical names (solnic)
* Fix the error message for missing association (flash-gordon)
* Curried relation called without any arguments will raise an ArgumentError (solnic)

[Compare v3.0.1...v3.0.2](https://github.com/rom-rb/rom/compare/v3.0.1...v3.0.2)

# v3.0.1 2017-02-01

## Fixed

* ViewDSL exposes schemas that have access to all relations (solnic)

[Compare v3.0.0...v3.0.1](https://github.com/rom-rb/rom/compare/v3.0.0...v3.0.1)

# v3.0.0 2017-01-29

## Added

* Support for schemas in view definitions via `schema do ... end` block (evaluated in the context of the canonical schema) (solnic)
* Schemas have their own types with adapter-specific APIs (solnic)
* Schema attributes include meta properties `source` and `target` (for FKs) (solnic)
* Inferred schemas can have explicit attribute definitions for cases where inference didn't work (solnic)
* New schema APIs: `#project`, `#rename`, `#exclude`, `#prefix`, `#wrap`, `#merge`, `#append` and `#uniq` (solnic)
* New schema attribute APIs: `#name`, `#aliased`, `#aliased?`, `#prefixed`, `#prefixed?`, `#wrapped`, `#wrapped?`, `#source`, `#target`, `#primary_key?`, `#foreign_key?` (solnic)
* Schemas are coercible to arrays that include all attribute types (solnic)
* Automatic relation view projection via `Schema#call` (abstract method for adapters) (solnic)
* `Relation#new(dataset, new_opts)` interface (solnic)
* `Relation#[]` interface for convenient access to schema attributes (solnic)
* `Command` has now support for `before` and `after` hooks (solnic)
* Support for `read` types in schemas, these are used when relation loads its tuples (solnic)
* New `Command#before` method for creating a command with before hook(s) at run-time (solnic)
* New `Command#after` method for creating a command with after hook(s) at run-time (solnic)
* New `Gateway#transaction` method runs code inside a transaction (flash-gordon)

## Changed

* [BREAKING] All relations have schemas now, empty by default (solnic)
* [BREAKING] `view` DSL is now part of the core relation API (solnic)
* [BREAKING] `view` DSL is based on schemas now, `header` was replaced with `schema` (solnic)
* [BREAKING] Deprecated `Command.validator` was removed (solnic)
* [internal] Renamed `relation` => `target` meta property in FK types (solnic)
* [internal] Use deprecations API from dry-core (flash-gordon)
* [internal] Use common constants from dry-core (EMPTY_HASH, EMPTY_ARRAY etc.) (flash-gordon)
* [internal] Internal ROM modules (array_dataset, enumerable_dataset, auto_curry, and data_proxy) were moved from rom-support to ROM itself (flash-gordon)
* [internal] rom-support dependency was removed (flash-gordon)

[Compare v2.0.2...v3.0.0](https://github.com/rom-rb/rom/compare/v2.0.2...v3.0.0)

# v2.0.2 2016-11-11

## Added

* API docs for `ROM::Container` (solnic)

## Fixed

* Custom command input function is no longer overridden by schema hash (solnic)
* `Relation::Name#to_s` returns a string properly when there is no alias (solnic)

[Compare v2.0.1...v2.0.2](https://github.com/rom-rb/rom/compare/v2.0.1...v2.0.2)

# v2.0.1 2016-09-30

### Added

- Support for different auto-registration strategies (janjiss)
- Support for custom component dir names in auto-registration (AMHOL)

### Fixed

- Finalizing schema that is already finalized no longer crashes (flash-gordon)

[Compare v2.0.0...v2.0.1](https://github.com/rom-rb/rom/compare/v2.0.0...v2.0.1)

# v2.0.0 2016-07-27

### Added

- Extendible `schema` DSL for relations with attribute and type definitions (solnic)
- New command plugin `:schema` which will set up an input handler from schema definition (solnic)
- New command option `restrictible` for commands that can use a restricted relation (solnic)
- More meaningful exception is raised when trying to access a non-existant command (thiagoa)
- `Relation::Name` class that contains both relation and dataset names (flash-gordon)
- `Relation::Loaded#pluck` returning values under specified key (solnic)
- `Relation::Loaded#primary_keys` returning a list of primary keys from a materialized relation (solnic)

#### New low-level APIs

- `Command.create_class` for building a command class dynamically (solnic)
- `Command.extend_for_relation` for extending a command with relation view interface (solnic)

### Fixed

- [BREAKING] command graphs return materialized results (a hash or an array) (solnic)
- `Container#disconnect` properly delegates to gateways (endash)
- `Relation#with` properly carries original options (solnic)
- Command pipeline will stop processing if result was `nil` or an empty array (solnic)

### Changed

- [BREAKING] `ROM.env` **is gone** (solnic)
- [BREAKING] `Update` and `Delete` no longer calls `assert_tuple_count` [more info](https://github.com/rom-rb/rom/commit/bec2c4c1dce370670c90f529feb1b4db0e6e4bd9) (solnic)
- [BREAKING] `Relation#name` and `Command#name` now returns `Relation::Name` instance (flash-gordon)
- `Command.validator` is now deprecated [more info](https://github.com/rom-rb/rom/commit/80bb8411bd411f05d9c51106ae026ad412a2f25f) (solnic)
- `Relation.dataset` yields a relation class when block was passed (solnic)
- `Relation#attributes` can return attributes explicitly passed via options (solnic)
- Relation `:key_inference` plugin supports schema information from other relations (solnic)
- `auto_registration` coerces its directory to a pathname now (adz)
- `macros` are now enabled by default in in-line setup block (endash)

[Compare v1.0.0...v2.0.0](https://github.com/rom-rb/rom/compare/v1.0.0...v2.0.0)

# v1.0.0 2016-01-06

### Added

- Command graph DSL (endash + solnic)
- Command graph now supports update and delete commands (cflipse + solnic)
- `Gateway.adapter` setting and a corresponding `Gateway#adapter` reader. Both are
  necessary to access a migrator (nepalez)
- `ROM::Commands::Result#{success?,failure?}` interface (Snuff)
- Imported relation plugins from `rom-repository`:
  - `view` for explicit relation view definitions
  - `key_inference` for inferring `foreign_key` of a relation

### Changed

- **REMOVED** all deprecated APIs (solnic)
- [fixed #306] Inheriting from a misconfigured adapter relation will raise a
  meaningful error (solnic)
- Command graph will raise `ROM::KeyMissing` command error when a key is missing
  in the input (solnic)
- Command graph no longer rescues from any exception (solnic)

### Fixed

- `Relation.register_as` properly overrides inherited value (solnic)

[Compare v0.9.1...v1.0.0](https://github.com/rom-rb/rom/compare/v0.9.1...v1.0.0)

# v0.9.1 2015-08-21

This is a small bug-fix release which addresses a couple of issues for inline
setup DSL and multi-environments.

### Fixed

- Multi-env setup for adapters with schema-inferration support won't crash (solnic)
- Default adapter is set correctly when many adapters are configured and one is
  registered under `:default` name (solnic)
- When defining a relation using inline DSL with custom dataset name the relation
  name will be correctly set as `register_as` setting (solnic)

### Changed

- When using inline-setup for env the auto_registration mechanism will be turned
  on by default (solnic)

[Compare v0.9.0...v0.9.1](https://github.com/rom-rb/rom/compare/v0.9.0...v0.9.1)

# v0.9.0 2015-08-19

### Added

* Configuration API for gateways supporting following options:
  - `infer_relations` either `true` or `false` - if disabled schema inference
    won't be used to automatically set up relations for you
  - `inferrable_relations` a list of allowed relations that should be inferred
  - `not_inferrable_relations` a list of relations that should not be inferred

### Changed

* Global setup with auto-registration ported to the `:auto_registration` environment plugin (AMHOL)
* Multi-environment setup possible now via `ROM::Environment` object (AMHOL)
* All relations are now lazy with auto-currying enabled (solnic)
* Low-level query DSL provided by adapters is now public but using it directly in
  application layer is discouraged (solnic)
* `ROM::Mapper` component extracted into standalone `rom-mapper` gem (solnic)
* Support libraries extracted to `rom-support` gem (solnic)

## Fixed

* `register_as` is now properly inferred for relations and their descendants (solnic)
* Adapter-specific interface is properly included in relation descendants (solnic)
* Combined commands (aka command graph) properly rejects keys from nested input
  prior sending the input to individual commands (solnic)
* Composite relation materializes correctly when another composite on the right
  side became materialized (ie piping relation through a composite relation will
  work correctly) (solnic)

[Compare v0.8.1...v0.9.0](https://github.com/rom-rb/rom/compare/v0.8.1...v0.9.0)

# v0.8.1 2015-07-12

### Fixed

* `ROM::CommandError` properly sets original error and backtrace (solnic)

### Changed

* Internal transproc processor has been updated to the new API (solnic)

[Compare v0.8.0...v0.8.1](https://github.com/rom-rb/rom/compare/v0.8.0...v0.8.1)

# v0.8.0 2015-06-22

### Added

* Commands can be combined into a single command that can work with a nested input (solnic)
* New `step` mapper operation that allows multistep transformations inside a single mapper (dekz)
* New `ungroup` and `unfold` mapper operations inverse `group` and `fold` (nepalez)
* Support deep nesting of `unwrap` mapper operations (nepalez)
* Support usage of `exclude` in a root of the mapper (nepalez)
* Support usage of `prefix` and `prefix_separator` mapper operations inside blocks (nepalez)
* Support renaming of the rest of an attribute after `unwrap` (nepalez)

### Changed

* `Repository` class has been renamed to `Gateway` with proper deprecation
  warnings (cflipse)
* `combine` in mapper can be used without a block (kwando)
* `wrap` and `group` in mapper will raise error if `:mapper` is set along with
  block or options (vrish88)

### Fixed

* `order` memory repository operation sorts tuples containing empty values (nepalez)
* `Mapper::AttributeDSL#embedded` now honors `option[:type]` when used
  with `option[:mapper]` (c0)

[Compare v0.7.1...v0.8.0](https://github.com/rom-rb/rom/compare/v0.7.1...v0.8.0)

# v0.7.1 2015-05-22

### Added

* Support for passing a block for custom coercion to `attribute` (gotar)
* `fold` mapping operation which groups keys from input tuples to array
  of values from the first of listed keys (nepalez)
* Adapter `Relation` and command classes can specify `adapter` identifier
  which allows using adapter-specific plugins w/o the need to specify adapter
  when calling `use` (solnic)

### Changed

* [rom/memory] `restrict` operation supports array as a value (gotar)
* [rom/memory] `restrict` operation supports regexp as a value (gotar)

[Compare v0.7.0...v0.7.1](https://github.com/rom-rb/rom/compare/v0.7.0...v0.7.1)

# v0.7.0 2015-05-17

### Added

* `combine` interface in Relation and Mapper which allows simple and explicit
  eager-loading that works with all adapters (solnic)
* `reject_keys` option in mapper which will filter out unspecified keys from
  input tuples (solnic)
* `unwrap` mapping operation (aflatter)
* Arbitrary objects can be registered as mappers via `register` in mapping DSL (solnic)
* Ability to reuse existing mappers in `group`, `wrap` and `embedded` mappings (solnic)
* Plugin interface for Relation, Mapper and Command (cflipse)
* `Memory::Dataset` accepts options hash now which makes it more flexible for
  any adapter that wants to subclass it (solnic)
* `ROM::Memory::Relation#take` (solnic)

### Changed

* [BREAKING] `Command#call` applies curried args first (solnic)
* `Commands::Update#set` was deprecated in favor of `call` (solnic)
* `group` mapping reject empty tuples (solnic)

### Fixed

* `Command` respond to missing properly now (solnic)
* `Mapper::DSL` respond to missing properly now (solnic)

### Internal

* Fixed all the warnings \o/ (splattael)
* Introduced `Deprecations` helper module (solnic)

[Compare v0.6.2...v0.7.0](https://github.com/rom-rb/rom/compare/v0.6.2...v0.7.0)

# v0.6.2 2015-04-14

### Changed

* Updated to transproc 0.2.0 (solnic)

### Fixed

* `CommandRegistry#respond_to_missing?` behavior (hecrj)

[Compare v0.6.1...v0.6.2](https://github.com/rom-rb/rom/compare/v0.6.1...v0.6.2)

# v0.6.1 2015-04-04

### Added

* Ability to auto-map command result via `rom.command(:rel_name).as(:mapper_name)` (solnic)

### Changed

* gemspec no longer specifies required_ruby_version so that rom can be installed on jruby (solnic)
* Obsolete `Env#readers` was removed (splattael)

[Compare v0.6.0...v0.6.1](https://github.com/rom-rb/rom/compare/v0.6.0...v0.6.1)

# v0.6.0 2015-03-22

### Added

* It is now possible to define custom relation, mapper and command classes during setup (solnic)
* New `Env#relation` interface for reading and mapping relations which supports:
  * `Relation::Lazy` with auto-currying, mapping and composition features (solnic)
  * `Relation::Composite` allowing data-pipelining with arbitrary objects (solnic)
  * Passing a block which yields relation with adapter query DSL available (solnic)
* Relations can be extended with plugins using Options API (solnic)
* Commands are now composable via `>>` operator (solnic)
* Mappers support `prefix_separator` option (solnic)
* Mappers can be registered under custom names (solnic)
* Relation `dataset` name is inferred from the class name by default (gotar)
* Relation can be registered under a custom name via `register_as` option (mcls)
* Adapters can use helper modules for datasets: `ArrayDataset` and `EnumerableDataset` (solnic)
* Adapter interface can now be tested via a lint test (elskwid + solnic + splattael)
* `tuple_count` interface in AbstractCommand which can be overridden by adapter (solnic)
* Custom Inflector API that auto-detects a specific inflection engine (mjtko)

### Changed

* [BREAKING] Schema DSL was **removed** - attributes can be specified only in mapper DSL
* [BREAKING] Reader was **removed** in favor of relation interface with explicit mapping (solnic)
* [BREAKING] Command API was simplified - commands should be accessed directly in `.try` block
  and default repository can be changed when defining a relation (solnic)
* `.setup` interface requires either an adapter identifier or can accept a repository
  instance (aflatter)
* Adapter interface no longer requires specific constructor to be defined (aflatter)
* Adapters no longer need to handle connection URIs (aflatter)
* Adapter/Repository has been collapsed to *just* `Repository` (solnic)
* Relation no longer needs a header object and only operates on an adapters dataset (solnic)
* Relation no longer uses on Charlatan with method_missing magic (solnic)
* Adapter's dataset no longer requires header (solnic)
* Make storage in memory adapter thread-safe #110 (splattael)
* An Adapter can provide its own Relation subclass with custom behavior (solnic)
* Relation provides its "public interface" using method_added hook (splattael + solnic)
* ROM no longer depends on charlatan, concord and inflecto gems (mjtko + solnic)

[Compare v0.5.0...v0.6.0](https://github.com/rom-rb/rom/compare/v0.5.0...v0.6.0)

# v0.5.0 2014-12-31

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

# v0.4.2 2014-12-19

### Added

* Mappers support tuple transformation using wrap and group operations (solnic)
* PORO model builder supports namespaced constants via `name: 'MyApp:Entities::User` (solnic)

### Changed

* `ROM::RA` interface is no longer mixed into relations by default (solnic)
* ~2.5 x speed up in aggregate mapping (solnic)
* PORO model builder only defines attribute readers now (no writers!) (solnic)
* Registry objects in Env will now raise `KeyError` when unknown name is referenced (solnic)

[Compare v0.4.1...v0.4.2](https://github.com/rom-rb/rom/compare/v0.4.1...v0.4.2)

# v0.4.1 2014-12-15

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

# v0.4.0 2014-12-06

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

# v0.3.1 2014-11-25

### Added

* attributes for `group` mapping operation can be specified without options (solnic)
* attributes for `wrap` mapping operation can be specified without options (solnic)
* `Env` uses Equalizer (solnic)
* boot dsl methods return self (solnic)

### Fixed

* when schema is missing booting will gracefuly skip building relations and mappers (solnic)
* in-memory join handles one-to-many and many-to-one correctly (solnic)

[Compare v0.3.0...v0.3.1](https://github.com/rom-rb/rom/compare/v0.3.0...v0.3.1)

# v0.3.0 2014-11-24

This version is a rewrite that introduces a new, simplified architecture based
on a new adapter interface.

[Compare v0.2.0...v0.3.0](https://github.com/rom-rb/rom/compare/v0.2.0...v0.3.0)

# v0.2.0 2014-04-06

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

# v0.1.2 2013-09-02

* [updated] [rom-relation](https://github.com/rom-rb/rom-relation/blob/v0.1.2/Changelog.md#v012-2013-09-02)

[Compare v0.1.1...v0.1.2](https://github.com/rom-rb/rom/compare/v0.1.1...v0.1.2)

# v0.1.1 2013-08-30

* [updated] [rom-relation](https://github.com/rom-rb/rom-relation/blob/v0.1.1/Changelog.md#v011-2013-08-30)
* [updated] [rom-session](https://github.com/rom-rb/rom-session/blob/v0.1.1/Changelog.md#v011-2013-08-30)

[Compare v0.1.0...v0.1.1](https://github.com/rom-rb/rom/compare/v0.1.0...v0.1.1)

# v0.1.0 2013-08-23

First public release
