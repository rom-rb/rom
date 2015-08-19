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
