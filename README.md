# Ruby Object Mapper

[![Gem Version](https://badge.fury.io/rb/rom.png)][gem]
[![Build Status](https://travis-ci.org/rom-rb/rom.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/rom-rb/rom.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/rom-rb/rom.png)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/rom-rb/rom/badge.png?branch=master)][coveralls]
[![Inline docs](http://inch-pages.github.io/github/rom-rb/rom.png)][inchpages]

[gem]: https://rubygems.org/gems/rom
[travis]: https://travis-ci.org/rom-rb/rom
[gemnasium]: https://gemnasium.com/rom-rb/rom
[codeclimate]: https://codeclimate.com/github/rom-rb/rom
[coveralls]: https://coveralls.io/r/rom-rb/rom
[inchpages]: http://inch-pages.github.io/github/rom-rb/rom/

Ruby Object Mapper is an implementation of [the Data Mapper](http://martinfowler.com/eaaCatalog/dataMapper.html)
pattern in Ruby language. It consists of multiple loosely coupled pieces and uses
a powerful relational algebra library called [axiom](https://github.com/dkubb/axiom).

## Getting started

Currently the setup is a bit verbose. Automatization will come in the future once
the API becomes stable.

```
gem install rom axiom-memory-adapter
```

### 1. Set up environment and define schema

```ruby
  require 'rom'
  require 'axiom-memory-adapter'

  env = ROM::Environment.setup(memory: 'memory://test')

  env.schema do
    base_relation :users do
      repository :memory

      attribute :id,   Integer
      attribute :name, String

      key :id
    end
  end
```

### 2. Set up mapping

```ruby
  class User
    attr_reader :id, :name

    def initialize(attributes)
      @id, @name = attributes.values_at(:id, :name)
    end
  end

  env.mapping do
    users do
      map :id, :name
      model User
    end
  end
```

### 3. Work with Plain Old Ruby Objects

```ruby
  env.session do |session|
    user = session[:users].new(id: 1, name: 'Jane')
    session[:users].save(user)
    session.flush
  end

  jane = env[:users].restrict(name: 'Jane').one
```

## Community

* #rom-rb channel on freenode
* [Ruby Object Mapper](https://groups.google.com/forum/#!forum/rom-rb) mailing list

## Authors

* [Dan Kubb](https://github.com/dkubb)
* [Markus Schirp](https://github.com/mbj)
* [Martin Gamsjaeger](https://github.com/snusnu)
* [Piotr Solnica](https://github.com/solnic)

## License

See `LICENSE` file.
