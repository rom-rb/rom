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

ROM.setup(:sql, 'sqlite::memory')

conn = ROM::SQL.gateway.connection

conn.create_table(:users) do
  primary_key :id
  column :name, String
end

conn.create_table(:tasks) do
  primary_key :id
  foreign_key :user_id, :users
  column :title, String
end

jane_id = conn[:users].insert name: 'Jane'
joe_id = conn[:users].insert name: 'Joe'

conn[:tasks].insert user_id: joe_id, title: 'Joe Task'
conn[:tasks].insert user_id: jane_id, title: 'Jane Task'

class Users < ROM::Relation[:sql]
end

class Tasks < ROM::Relation[:sql]
  def for_users(users)
    where(user_id: users.map { |u| u[:id] })
  end
end

class UserRepository < ROM::Repository::Base
  relations :users, :tasks

  def by_id(id)
    users.where(id: id)
  end

  def with_tasks
    users.combine(many: { tasks: tasks.for_users })
  end
end

rom = ROM.finalize.env

user_repo = UserRepository.new(rom)

puts user_repo.by_id(1).to_a.inspect
# [#<ROM::Struct[User] id=1 name="Jane">]

puts user_repo.with_tasks.to_a.inspect
# [#<ROM::Struct[User] id=1 name="Jane" tasks=[#<ROM::Struct[Task] id=2 user_id=1 title="Jane Task">]>, #<ROM::Struct[User] id=2 name="Joe" tasks=[#<ROM::Struct[Task] id=1 user_id=2 title="Joe Task">]>]
```
