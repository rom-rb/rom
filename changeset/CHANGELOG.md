# 1.0.0 to-be-released

rom-changeset was extracted from rom-repository

### Added

- `#changeset` interfaced was ported to a relation plugin and now `Relation#changeset` is available (solnic)

### Changed

- Changesets are no longer coupled to repositories (solnic)
- Changesets use relations to retrieve their commands (solnic)
