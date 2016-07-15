[gem]: https://rubygems.org/gems/rom-repository
[travis]: https://travis-ci.org/rom-rb/rom-repository
[gemnasium]: https://gemnasium.com/rom-rb/rom-repository
[codeclimate]: https://codeclimate.com/github/rom-rb/rom-repository
[inchpages]: http://inch-ci.org/github/rom-rb/rom-repository

# rom-repository

[![Gem Version](https://badge.fury.io/rb/rom-repository.svg)][gem]
[![Build Status](https://travis-ci.org/rom-rb/rom-repository.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/rom-rb/rom-repository.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/rom-rb/rom-repository/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/rom-rb/rom-repository/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/rom-rb/rom-repository.svg?branch=master)][inchpages]

Repository for [ROM](https://github.com/rom-rb/rom) with auto-mapping and relation
extensions.

## Conventions & Definitions

Repositories in ROM are simple objects that allow you to compose rich relation
views specific to your application layer. Every repository can access multiple
relations that you define and use them to build more complex views.

Repository relations are enhanced with a couple of extra features on top of ROM
relations:

- Every relation has an auto-generated mapper which turns raw data into simple, immutable structs
- `Relation#combine` can accept a simple hash defining what other relations should be joined
- `Relation#combine_parents` automatically joins parents using eager-loading
- `Relation#combine_children` automatically joins children using eager-loading
- `Relation#wrap_parent` automatically joins a parent using inner join

### Relation Views

A relation view is a result of some query which returns results specific to your
application. You can define them using a simple DSL where you specify a name, what
attributes resulting tuples will have and of course the query itself:

``` ruby
class Users < ROM::Relation[:sql]
  view(:by_id, [:id, :name]) do |id|
    where(id: id).select(:id, :name)
  end

  view(:listing, [:id, :name, :email, :created_at]) do
    select(:id, :name, :email, :created_at).order(:name)
  end
end
```

This way we can explicitly define all our relation view that our application will
depend on. It encapsulates access to application-specific data structures and allows
you to easily test individual views in isolation.

Thanks to explicit definition of attributes mappers are derived automatically.

### Auto-combine & Auto-wrap

Repository relations support automatic `combine` and `wrap` by using a simple
convention that every relation defines `for_combine(keys, other)` and `for_wrap(keys, other)`.

You can override the default behavior for combine by defining `for_other_rel_name`
in example, if you combine tasks with users you can define `Tasks#for_users` and
this will be used instead of the generic `for_combine`.

### Mapping & Structs

Currently repositories map to `ROM::Struct` by default. In the near future this
will be configurable.

ROM structs are simple and don't expose an interface to mutate them; however, they
are not being frozen (at least not yet, we could add a feature for freezing them).

They are coercible to `Hash` so it should be possible to map them further in some
special cases using ROM mappers.

``` ruby
class Users < ROM::Relation[:sql]
  view(:by_id, [:id, :name]) do |id|
    where(id: id).select(:id, :name)
  end

  view(:listing, [:id, :name, :email, :created_at]) do
    select(:id, :name, :email, :created_at).order(:name)
  end
end

class UserRepository < ROM::Repository::Base
  relations :users, :tasks

  def by_id(id)
    users.by_id(id)
  end

  def with_tasks(id)
    users.by_id(id).combine_children(many: tasks)
  end
end

rom = ROM.finalize.env

user_repo = UserRepository.new(rom)

puts user_repo.by_id(1).to_a.inspect
# [#<ROM::Struct[User] id=1 name="Jane">]

puts user_repo.with_tasks.to_a.inspect
# [#<ROM::Struct[User] id=1 name="Jane" tasks=[#<ROM::Struct[Task] id=2 user_id=1 title="Jane Task">]>, #<ROM::Struct[User] id=2 name="Joe" tasks=[#<ROM::Struct[Task] id=1 user_id=2 title="Joe Task">]>]
```

### Using Custom Model Types

To use a custom model type you simply use the standard `Relation#as` inteface
but you can pass a constant:

``` ruby
class UserRepository < ROM::Repository::Base
  relations :users, :tasks

  def by_id(id)
    users.by_id(id).as(User)
  end
end
```

## License

See `LICENSE` file.
