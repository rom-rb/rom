[gem]: https://rubygems.org/gems/rom
[travis]: https://travis-ci.org/rom-rb/rom
[gemnasium]: https://gemnasium.com/rom-rb/rom
[codeclimate]: https://codeclimate.com/github/rom-rb/rom
[coveralls]: https://coveralls.io/r/rom-rb/rom
[inchpages]: http://inch-ci.org/github/rom-rb/rom/

# Ruby Object Mapper [![Gitter chat](https://badges.gitter.im/rom-rb/chat.svg)](https://gitter.im/rom-rb/chat) [![Stories in Ready](https://badge.waffle.io/rom-rb/rom.png?label=ready&title=Ready)](https://waffle.io/rom-rb/rom)

[![Gem Version](https://badge.fury.io/rb/rom.svg)][gem]
[![Build Status](https://travis-ci.org/rom-rb/rom.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/rom-rb/rom.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/rom-rb/rom/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/rom-rb/rom/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/rom-rb/rom.svg?branch=master&style=flat)][inchpages]

Ruby Object Mapper (ROM) is an experimental Ruby library with the goal to
provide powerful object mapping capabilities without limiting the full power of
your datastore.

Learn more:

* [Introduction](http://rom-rb.org/introduction/)
* [Rails tutorial](http://rom-rb.org/tutorials/todo-app-with-rails/)

## Adapters

  * [rom-sql](https://github.com/rom-rb/rom-sql)
  * [rom-yesql](https://github.com/rom-rb/rom-yesql)
  * [rom-mongo](https://github.com/rom-rb/rom-mongo)
  * [rom-yaml](https://github.com/rom-rb/rom-yaml)
  * [rom-csv](https://github.com/rom-rb/rom-csv)
  * [rom-neo4j](https://github.com/rom-rb/rom-neo4j)
  * [rom-event_store](https://github.com/rom-rb/rom-event_store)
  * [rom-influxdb](https://github.com/rom-rb/rom-influxdb)
  * [rom-rethinkdb](https://github.com/rom-rb/rom-rethinkdb)

See [issues](https://github.com/rom-rb/rom/issues?q=is%3Aopen+is%3Aissue+label%3Aadapter+label%3Afeature)
for a list of adapters that are planned to be added soon.

## Framework integrations

* [rom-lotus](https://github.com/rom-rb/rom-lotus)
* [rom-rails](https://github.com/rom-rb/rom-rails)
* [rom-roda](https://github.com/rom-rb/rom-roda)

## Synopsis

``` ruby
ROM.setup(:memory)

# This is our domain-specific class
class User
  attr_reader :name, :age

  def initialize(attributes)
    @name, @age = attributes.values_at(:name, :age)
  end
end

# Here we define user relation which encapsulates accessing user data that
# we can map to domain objects
class Users < ROM::Relation[:memory]
  def by_name(name)
    restrict(name: name)
  end

  def adults
    restrict { |user| user[:age] >= 18 }
  end
end

# Even though mappers can be derived from model definitions here's how you
# could define it explicitly
class UserMapper < ROM::Mapper
  relation :users
  register_as :entity

  model User

  attribute :name
  attribute :age
end

# You can define specialized commands that handle creating, updating and deleting
# data, those classes can use external input param handlers and validators too
class CreateUser < ROM::Commands::Create[:memory]
  register_as :create
  relation :users
  result :one
end

# finalize the setup and retrieve object registry (aka ROM env)
rom = ROM.finalize.env

# accessing defined commands
rom.command(:users).create.call(name: "Joe", age: 17)
rom.command(:users).create.call(name: "Jane", age: 18)

# reading relations using defined mappers
puts rom.relation(:users) { |r| r.by_name("Jane").adults }.as(:entity).to_a.inspect
# => [#<User:0x007fdba161cc48 @id=2, @name="Jane", @age=18>]
```

## ROADMAP

ROM is on its way towards 1.0.0. You can see an overview of tasks scheduled for 1.0.0 on our [waffle board](https://waffle.io/rom-rb/rom?label=1.0.0). Please notice that most of the 1.0.0 features/changes will become part of minor (0.x) upgrades before 1.0.0 final gets released.

## Community

* [Official Blog](http://rom-rb.org/blog/)
* [Ruby Object Mapper](https://groups.google.com/forum/#!forum/rom-rb) mailing list

## Credits

This project has a long history and wouldn't exist without following people:

 * [Dan Kubb](https://github.com/dkubb)
 * [Markus Schirp](https://github.com/mbj)
 * [Martin Gamsjaeger](https://github.com/snusnu)

## License

See `LICENSE` file.
