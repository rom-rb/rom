# rom-repository

This is my playground for some higher-level repository abstraction on top of ROM
pieces which is supposed to do the following:

* a repository loads data from its relation(s) into simple struct objects
* a repository generates dedicated mappers on-the-fly by reflecting on a relation structure
* a repository generates dedicated classes for representing data (simple structs)

This is based on a couple of assumptions. First of all **relation data are represented
as structs** so you don't define your "entities" because a repository will always
give you structs back. You can, however, decorate structs using your own entity
classes when needed.

Secondly it will only work with adapters that provide an interface to inspect its
relation headers. Typically most adapters will be able to do that so we should be
fine.

Few ideas about structs:

* structs will be immutable
* structs will have standard attr readers
* structs will have hash-like `[]` readers too
* structs will raise an error when you try to access a non-existant attribute
* structs will be extremely simple wrt their interface

## Synopsis

``` ruby
require 'rom-repository'

ROM.setup(:sql, 'postgres://localhost/rom')

class UserRepository < ROM::Repository::Base
  relations :users, :tasks

  def by_id(id)
    users.where(id: id)
  end

  def with_tasks
    combine(users, many: { tasks: tasks.order(:title) })
  end
end

rom = ROM.finalize.env

user_repo = UserRepository.new(rom)

puts user_repo.by_id(1).to_a.inspect
# [#<ROM::Struct[User] id=1 name="Jane">]

puts user_repo.with_tasks.to_a.inspect
# [#<ROM::Struct[User] id=1 name="Jane" tasks=[#<ROM::Struct[Task] id=2 user_id=1 title="Jane Task">]>, #<ROM::Struct[User] id=2 name="Joe" tasks=[#<ROM::Struct[Task] id=1 user_id=2 title="Joe Task">]>]
```
