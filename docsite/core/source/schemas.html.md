---
chapter: Core
title: Schemas
---

Schemas define explicit attribute names and types within a relation. All adapters support relation schemas, and adapter-specific extensions can be provided as well, for example `rom-sql` extends schema DSL with support for database-specific types.

Apart from adapter-specific extensions, schemas can be *extended by you* since you can define your own *types* as well as your own custom methods available on attribute objects.

## Why?

First of all, because schemas give an explicit definition for the data structures a given relation returns.

Both **relations** and **commands** use schemas to process data, this gives you type-safe commands out-of-the-box, with optional ability to perform low-level database coercions (like coercing a hash to a PG hash etc.), as well as optional coercions when reading data.

Furthermore, schemas can provide meta-data that can be used to automate many common tasks, like generating relations automatically for associations.

## Defining schemas explicitly

The DSL is simple. Provide a symbol name with a type from the Types module:

``` ruby
class Users < ROM::Relation[:http]
  schema do
    attribute :id, Types::Int
    attribute :name, Types::String
    attribute :age, Types::Int
  end
end
```

## Inferring schemas

If the adapter that you use supports inferring schemas, your schemas can be defined as:

``` ruby
class Users < ROM::Relation[:sql]
  schema(infer: true)
end
```

You can also **override inferred attributes**:

``` ruby
class Users < ROM::Relation[:sql]
  schema(infer: true) do
    # this overrides inferred :meta attribute
    attribute :meta, Types::MyCustomMetaType
  end
end
```

## Types namespace

All builtin types are defined in `ROM::Types` namespace, and individual adapters may provide their own namespace which extends the builtin one. For example `rom-sql` provides `ROM::SQL::Types` and `ROM::SQL::Types::PG`.

## Primary keys

You can set up a primary key, either a single attribute or a composite:

``` ruby
class Users < ROM::Relation[:http]
  schema do
    attribute :id, Types::Int
    attribute :name, Types::String
    attribute :age, Types::Int

    primary_key :id
  end
end
```

For a composite primary key, pass the relevant attribute names:

``` ruby
class UsersGroups < ROM::Relation[:http]
  schema do
    attribute :user_id, Types::Int
    attribute :group_id, Types::Int

    primary_key :id, :group_id
  end
end
```

^INFO
`primary_key` is a shortcut for the annotation: Types::Int.meta(primary_key: true)
^

## Foreign Keys

You can set up foreign keys pointing to a specific relation:

``` ruby
class Posts < ROM::Relation[:http]
  schema do
    attribute :user_id, Types::ForeignKey(:users)
    # defaults to `Types::Int` but can be overridden:
    attribute :user_id, Types::ForeignKey(:users, Types::UUID)
  end
end
```

^INFO
`foreign_key` is a shortcut for the annotation: Types::Int.meta(foreign_key: true, relation: :users)
^

## Annotations

Schema types provide an API for adding arbitrary meta-information. This is mostly useful for adapters, or anything that may need to introspect relation schemas.

Here's an example:

``` ruby
class Users < ROM::Relation[:http]
  schema do
    attribute :name, Types::String.meta(namespace: 'details')
  end
end
```

Here we defined a `:namespace` meta-information, that can be used accessed via `:name` type:

``` ruby
Users.schema[:name].meta[:namespace] # 'details'
```

## Using `write` types

Relations commands will automatically use schema attributes when processing the input. This allows us to perform database-specific coercions, setting default values or applying low-level constraints.

Let's say our setup requires generating a UUID prior executing a command:

``` ruby
class Users < ROM::Relation[:http]
  UUID = Types::String.default { SecureRandom.uuid }

  schema do
    attribute :id, UUID
    attribute :name, Types::String
    attribute :age, Types::Int
  end
end
```

Now when you persist data using [repositories](/learn/repository/%{version}) or [commands](/learn/core/%{version}), your schema will be used to process the input data, and our `:id` value will be handled by the `UUID` type.

## Using `read` types

Apart from `write` types, you can also specify `read` types, these are used by relations when they read data from a database. You can define them using `:read` option:

``` ruby
class Users < ROM::Relation[:http]
  schema do
    attribute :id, Types::Serial
    attribute :name, Types::String
    attribute :birthday, Types::String, read: Types::Coercible::Date
  end
end
```

Now when `Users` relation reads it data, `birthday` values will be processed via `Types::Coercible::Date`.

## Type System

Schemas use a type system from [dry-types](http://dry-rb.org/gems/dry-types) and you can define your own schema types however you want. What types you need really depends on your application requirements, the adapter you're using, specific use cases of your application and so on.

Here are a couple of guidelines that should help you in making right decisions:

* Don't treat relation schemas as a complex coercion system that is used against
  data received at the HTTP boundary (ie rack request params)
* Coercion logic for input should be low-level (eg. Hash => PGHash in rom-sql)
* Default values should be used as a low-level guarantee that some value is
  **always set** before making a change in your database. Generating a unique id
  is a good example. For default values that are closer to your application domain
  it's better to handle this outside of the persistence layer. For example, setting
  `draft` as the default value for post's `:status` attribute is part of your domain
  more than it is part of your persistence layer.
* Strict types *can be used* and they will raise `TypeError` when invalid data
  was accidentally passed to a command. Use this with caution, typically you want
  to validate the data prior sending them to a command, but there might be use cases
  where you expect data to be valid already, and any type error *is indeed an exception*
  and you want your system to crash

## Learn more

You can learn more about adapter-specific schemas:

- [SQL schemas](/learn/sql/3.2/schemas)
