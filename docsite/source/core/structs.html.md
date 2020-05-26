---
chapter: Core
title: Structs
---

Relations return plain hashes by default, but it's more common to use simple objects with attribute readers to represent data in your application. These objects should be treated as pure data structures, that don't have to be mutated at run-time, and don't depend on any external systems (such as mailers, API clients, message buses etc.). Their methods should only deal with the attributes they encapsulate. It's also common to use structs as aggregate roots, in which case they may provide methods to simplify accessing data represented by aggregate children.

You can work with structs in 3 different ways:

1. Rely on `auto_struct` without defining custom struct classes - this works very well in the beginning of a project, where you don't need your own methods at all
2. Use `auto_struct` with custom struct classes - a nice middle-ground where you benefit from dynamic mapping but you also have access to your own methods
3. Use custom objects - the most advanced technique, where data are mapped to your own objects. This approach should be used in mature projects where complete separation from persistence layer is going to be beneficial.

^INFO
  Notice that you can use all 3 ways at the same time, depending on what makes sense in a given use case
^

## Auto-struct

Auto-struct is a relation feature which can automatically transform plain relation tuples to struct objects. These objects are instances of `ROM::Struct` and have explicit attributes defined, based on information from relation schemas.

You can enable this feature via `auto_struct(true)` in a relation class:

``` ruby
class Users < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      has_many :tasks
    end
  end
  
  auto_struct(true)
end

users.by_pk(1).one
=> #<User id=1 name="Jane">

users.by_pk(1).combine(:tasks).one
=> #<User id=1 name="Jane" tasks=[#<Task id=1 user_id=1 title="Jane's Task">]>
```

^WARNING
This feature is **enabled by default in repositories**.
^

## Auto-struct with custom classes

Relations support configuring `struct_namespace`, it is set to `ROM::Struct` by default, which means struct classes are generated for you automatically within `ROM::Struct` namespace. If you want to provide your own struct classes, simply put them in a module and configure it as the `struct_namespace`.

Let's say you have `Entities` namespace and would like to provide a custom `Entities::User` class:

``` ruby
module Entities
  class User < ROM::Struct
    def full_name
      "#{first_name} #{last_name}"
    end
  end
end

class Users < ROM::Relation[:sql]
  schema(infer: true)
  
  struct_namespace Entities
  auto_struct true
end

user = users.by_pk(1).one
user.full_name
# => "Jane Doe"
```

### How struct classes are determined

Mappers will look for struct classes based on `Relation#name`, but this is not restricted
to canonical names of your relations, as they can be aliased too. For instance, you may
define `:admins` relation, which is restricted to users with `type` set to `"Admin"`. Then
if you have a `Entities::Admin` class, it will be used as the struct class for `:admins`
relation.

``` ruby
module Entities
  class User < ROM::Struct
    def admin?
      false
    end
  end
  
  class Admin < User
    def admin?
      true
    end
  end
end

class Admins < ROM::Relation[:sql]
  dataset { where(type: "Admin") }

  schema(:users, as: :admins, infer: true)
  
  struct_namespace Entities
  auto_struct true
end

admin = admins.by_pk(1).one

admin.admin?
# true
```

^INFO
#### Usage with repositories

It is recommended to configure `struct_namespace` in repositories, as it's the appropriate layer where application-specific data structures are coming from.
^

## Mapping to custom objects

You can ask a relation to instantiate your own objects via `Relation#map_to` interface.
Your object class must have a constructor which accepts a hash with attributes.

Here's a simple example:

```ruby
class User
  attr_reader :attributes
  
  def initialize(attributes)
    @attributes = attributes
  end
  
  def [](name)
    attributes[name]
  end
end

users.by_pk(1).map_to(User)
# => #<User:0x007fa7eabf1a50 @attributes={:id=>1, :name=>"Jane"}>
```

## Learn more

* [api::rom](Struct)
