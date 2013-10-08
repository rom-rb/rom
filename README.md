# Ruby Object Mapper

Ruby Object Mapper is an implementation of [the Data Mapper](http://martinfowler.com/eaaCatalog/dataMapper.html)
pattern in Ruby language. It consists of multiple lously coupled pieces and uses
a powerful relational algebra library called [axiom](https://github.com/dkubb/axiom).

This is a meta-project grouping pieces of ROM's default stack:

* [rom-relation](https://github.com/rom-rb/rom-relation)
* [rom-mapper](https://github.com/rom-rb/rom-mapper)
* [rom-session](https://github.com/rom-rb/rom-session)

## Getting started

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

## Licence

See `LICENSE` file.
