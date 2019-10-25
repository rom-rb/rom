---
chapter: Core
title: Commands
---

Commands are used to make changes in your data. Every adapter provides its own command
specializations, that can use database-specific features.

Core commands include following types:

* `:create` - a command which inserts new tuples
* `:update` - a command which updates existing tuples
* `:delete` - a command which deletes existing tuples

## Working with commands

You can get a command object via `Relation#command` interface. All core command types are
supported by this method.

Assuming you have a users relation available:

### `:create`

``` ruby
# inserting a single tuple
create_user = users.command(:create)

create_user.call(name: "Jane")

# inserting a multiple tuples
create_user = users.command(:create, result: :many)

create_user.call([{ name: "Jane" }, { name: "John" }])
```

### `:update`

``` ruby
update_user = users.by_pk(1).command(:update)

update_user.call(name: "Jane Doe")
```

### `:delete`

``` ruby
delete_user = users.by_pk(1).command(:delete)

delete_user.call
```

## Using custom command types

You can define custom command types too. This is useful when the logic is complex and you prefer
to encapsulate it in a single class.

``` ruby
class MyCommand < ROM::SQL::Commands::Create
  relation :users
  register_as :my_command
  
  def execute(tuple)
    # do whatever you need
  end
end
```

When your command is available in the configured rom container, you can get it in the standard way:

``` ruby
my_command = users.command(:my_command)

my_command.call(name: "Jane")
```

## Commands vs Changesets

Commands are the underlying abstraction for making changes in your database, whereas changesets
should be treated as a more advanced abstraction, which provides additional data mapping functionality,
and support for associating data.

^INFO
For consistency, you should consider using changesets instead of commands; however, if you're processing
larger amounts of data, and performance is a concern, you may want to use commands instead.
^

Here are benchmarks showing you roughly performance difference between the two:

```
=> benchmark: create command vs changeset

Warming up --------------------------------------
             command   226.000  i/100ms
           changeset   152.000  i/100ms
Calculating -------------------------------------
             command      2.238k (±10.5%) i/s -     11.300k in   5.134520s
           changeset      1.416k (±17.1%) i/s -      6.840k in   5.035512s

Comparison:
             command:     2237.6 i/s
           changeset:     1415.6 i/s - 1.58x  slower


=> benchmark: update command vs changeset

Warming up --------------------------------------
             command    35.000  i/100ms
           changeset    21.000  i/100ms
Calculating -------------------------------------
             command    405.284  (± 3.5%) i/s -      2.030k in   5.014935s
           changeset    213.359  (± 4.2%) i/s -      1.071k in   5.028808s

Comparison:
             command:      405.3 i/s
           changeset:      213.4 i/s - 1.90x  slower


=> benchmark: delete command vs changeset

Warming up --------------------------------------
             command   230.000  i/100ms
           changeset   134.000  i/100ms
Calculating -------------------------------------
             command      2.280k (± 5.0%) i/s -     11.500k in   5.057193s
           changeset      1.452k (±14.9%) i/s -      7.102k in   5.044861s

Comparison:
             command:     2280.2 i/s
           changeset:     1451.5 i/s - 1.57x  slower
```
