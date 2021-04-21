---
chapter: Core
title: Mappers
---

Mappers are used to process relation data, this may involve merging results from multiple relations into nested data structures or instantiating custom objects. Relations generate their mappers automatically for most common use cases, but mappers are separated from relations, which means you can always define your own mappers, whenever you have the need.

## Default relation mappers

Relations are configured to map automatically to plain hashes by default. When you're using relations via repostories, they are configured to map to `ROM::Struct` by default, and you can define custom struct namespace, if you want your own objects to be instantiated instead.

Here's how default mapping looks like, assuming you have a users relation available:

``` ruby
class Users < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      has_many :tasks
    end
  end
end

users.by_pk(1).one
=> {:id=>1, :name=>"Jane"}

users.by_pk(1).combine(:tasks).one
=> {:id=>1, :name=>"Jane", :tasks=>[{:id=>1, :user_id=>1, :title=>"One"}, {:id=>2, :user_id=>1, :title=>"Two"}]}
```

## Using custom mappers

A mapper can be any object which responds to `#call`, which accepts a relation and return an array with results back. This means a simple proc will be just fine:

``` ruby
user_name_mapper = -> users { users.pluck(:name) }

user_names = users >> user_name_mapper

user_names.to_a
=> ["Jane", "John"]
```

Typically though, custom mappers will be used in more complex cases, when the underlying database doesn't provide enough functionality that's needed to get desired data structures. In such cases, you can define mapper classes and configure mapping there.

``` ruby
require 'rom/transformer'

class UserMapper < ROM::Transformer
  relation :users, as: :users_mapper

  # Each function in the pipeline is called in order and the row is sent as an argument.
  map do
    resolve_model
    create_instance
    # Any other functions you need.
  end

  # Find the model class for the row based on the content of its role
  # field, then add it to the row's data for next function to use it.
  def resolve_model(row)
    model_for = ->(row) do
      Object.const_get(Dry::Inflector.new.camelize(row[:role]))
    end

    row.to_h.merge(model: model_for.(row))
  end

  # Use the model class name in the row and the rest of its data
  # to create an instance of that model.
  def create_instance(row)
    model = row.delete(:model)
    model.new(row)
  end
end

```
The result of the pipeline in the mapper above will be an instance of the right model class for the given `users` relation row, according to its `:role` field.

With a custom mapper configured, you can use `Relation#map_with` interface to send relation data through your mapper:

``` ruby
users.map_with(:my_mapper).to_a
```

`ROM::Transformer` is powered by [transproc](https://github.com/solnic/transproc#transformer).

## Learn more

* [Structs](/learn/core/%{version}/structs)
* [api::rom::Relation](.schema)
* [api::rom::Relation](.auto_struct)
* [api::rom::Relation](.struct_namespace)
* [api::rom::Relation](#map_to)
* [api::rom::Relation](#map_with)
* [api::rom](Transformer)
