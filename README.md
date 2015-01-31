[gem]: https://rubygems.org/gems/rom
[travis]: https://travis-ci.org/rom-rb/rom
[gemnasium]: https://gemnasium.com/rom-rb/rom
[codeclimate]: https://codeclimate.com/github/rom-rb/rom
[coveralls]: https://coveralls.io/r/rom-rb/rom
[inchpages]: http://inch-ci.org/github/rom-rb/rom/

# Ruby Object Mapper

[![Gem Version](https://badge.fury.io/rb/rom.svg)][gem]
[![Build Status](https://travis-ci.org/rom-rb/rom.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/rom-rb/rom.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/rom-rb/rom/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/rom-rb/rom/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/rom-rb/rom.svg?branch=master&style=flat)][inchpages]

Ruby Object Mapper (ROM) is an experimental Ruby library with the goal to
provide powerful object mapping capabilities without limiting the full power of
your datastore.

Learn more:

* [Introduction](http://rom-rb.org/introduction/)
* [Rails tutorial](http://rom-rb.org/tutorials/rails/)

## Adapters

  * [rom-sql](https://github.com/rom-rb/rom-sql)
  * [rom-mongo](https://github.com/rom-rb/rom-mongo)
  * [rom-yaml](https://github.com/rom-rb/rom-yaml)
  * [rom-csv](https://github.com/rom-rb/rom-csv)

See [issues](https://github.com/rom-rb/rom/issues?q=is%3Aopen+is%3Aissue+label%3Aadapter+label%3Afeature)
for a list of adapters that are planned to be added soon.

ROM can be used with Rails next to ActiveRecord via [rom-rails](https://github.com/rom-rb/rom-rails) railtie.
Integration with other frameworks is planned.

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
class UserRelation < ROM::Relation[:memory]
  base_name :users

  def by_name(name)
    restrict(name: name)
  end

  def adults
    find_all { |user| user[:age] >= 18 }
  end
end

# Even though mappers can be derived from model definitions here's how you
# could define it explicitly
class UserMapper < ROM::Mapper
  relation :users

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
rom.command(:users).try { create(name: "Joe", age: 17) }
rom.command(:users).try { create(name: "Jane", age: 18) }

# reading relations using defined mappers
puts rom.read(:users).by_name("Jane").adults.to_a.inspect
# => [#<User:0x007fdba161cc48 @id=2, @name="Jane", @age=18>]
```

## ROADMAP

ROM is on its way towards 1.0.0. Please refer to [issues](https://github.com/rom-rb/rom/issues)
for details.

## Community

* [Official Blog](http://rom-rb.org/blog/)
* [![Gitter chat](https://badges.gitter.im/rom-rb/chat.png)](https://gitter.im/rom-rb/chat)
* [Ruby Object Mapper](https://groups.google.com/forum/#!forum/rom-rb) mailing list

## Credits

This project has a long history and wouldn't exist without following people:

 * [Dan Kubb](https://github.com/dkubb)
 * [Markus Schirp](https://github.com/mbj)
 * [Martin Gamsjaeger](https://github.com/snusnu)

## License

See `LICENSE` file.
