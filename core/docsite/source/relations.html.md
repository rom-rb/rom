---
chapter: Core
title: Relations
---

Relations are really the heart of ROM. They provide APIs for reading the data
from various databases, and low-level interfaces for making changes in the databases.
Relations are adapter-specific, which means that each adapter provides its own
relation specialization, exposing interfaces that make it easy to leverage the
features of your database. At the same time, these relations encapsulate data
access, so that details about how it's done don't leak into your application domain
layer.

## Relation classes

In typical setup of an application using ROM, relations are defined as explicit
classes. You can put them in separate files, namespace them or not, and configure
them when it's needed (especially useful when using a legacy database with non-standard
naming conventions).

The most important responsibility of relations is to expose a clear API for reading
data. Every relation *method* should return another relation, we call them
<mark>relation views</mark>. These views can be defined in ways that make them
*composable* by including combine-keys in the resulting tuples. This is not limited
to SQL, you can compose data from different sources.

### Example relation class

Let's say we have a `:users` table in a SQL database, here's how you would define
a relation class for it:

``` ruby
class Users < ROM::Relation[:sql]
  schema(infer: true)
end
```

Notice a few things:

- `ROM::Relation[:sql]` uses `:sql` identifier to resolve a relation type for the `rom-sql`
  adapter
- `Users` class name is used by default to infer the `dataset` name and set it to `:users`
- `schema` is configured to be inferred from the database schema, and it will include
  attributes based on all table columns

### Relation methods

Every method in a relation should return another relation, this happens automatically
whenever you use a query interface provided by adapters. In our example we use
`rom-sql`, let's define a relation view called `listing`, using SQL query DSL:

``` ruby
class Users < ROM::Relation
  def listing
    select(:id, :name, :email).order(:name)
  end
end
```

## Materializing relations

To materialize a relation means asking it to load its data from a database. Relations can be materialized in a couple of ways, and you should be cautious about when it's happening, so that the minimum amount of interactions with a database takes place.

### Getting all results

To get all results, simply coerce a relation to an array via `Relation#to_a`:

``` ruby
users.to_a
=> [{:id=>1, :name=>"Jane Doe"}, {:id=>2, :name=>"John Doe"}]
```

### Getting a single result

To materialize a relation and retrieve just a single result, use `#one` or `#one!`:

```ruby
# Produces a single result or nil if none found.
# Raises an error if there are more than one.
users.one

# Produces a single tuple.
# Raises an error if there are 0 results or more than one.
users.one!
```

### Iteration

If you start iterating over a relation via `Relation#each`, the relation will get its data via `#to_a` and yield results to the block.

``` ruby
users.each do |user|
  puts user[:name]
end
# Jane Doe
# John Doe
```

### Next

Now let's see how you can use [relation schemas](/learn/core/%{version}/schemas).
