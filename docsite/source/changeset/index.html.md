---
position: 2
chapter: Changeset
title: Introduction
sections:
  - mapping
  - associations
---

Changesets are an advanced abstraction for making changes in your database. They work on top of commands, and provide additional data mapping functionality and have support for associating data.

Built-in changesets support all core command types, you can also define custom changeset classes and connect them to custom commands.

## Working with changesets

You can get a changeset object via `Relation#changeset` interface. A changeset object wraps input data, and may optionally convert it into a representation that's compatible with your database schema.

Assuming you have a users relation available:

### `:create`

``` ruby
users.changeset(:create, name: "Jane").commit
=> {:id=>1, :name=>"Jane"}
```

### `:update`

``` ruby
users.by_pk(4).changeset(:update, name: "Jane Doe").commit
=> {:id=>4, :name=>"Jane Doe"}
```

^WARNING
#### Checking diffs
  Update changesets check the difference between the original tuple and new data. If there's no diff, an update changeset **will not execute its command**.
^

### `:delete`

``` ruby
users.by_pk(4).changeset(:delete).commit
=> {:id=>4, :name=>"Jane Doe"}

users.by_pk(4).changeset(:delete).commit
# => nil
```

^INFO
In the examples above, we used `Relation#by_pk` method, this is a built-in method which restricts a relation by its primary key; however, you can use any method that's available, including native adapter query methods.
^

## Learn more

* [api::rom](Changeset)
* [api::rom::Changeset](Create)
* [api::rom::Changeset](Update)
* [api::rom::Changeset](Delete)
* [api::rom::Changeset](Associated)
