---
chapter: Core
title: Associations
---

Associations in ROM are based on Relation API, you can configure them using `associations`
block in schema definition. All adapters have access to this API and you can define
associations between different databases too.

## Association model explained

Using associations means **composing relations**, it is really important to understand this,
as it gives you a lot of freedom in the way you fetch complex data structures from your database.

Here's how it works using plain Ruby:

``` ruby
users = [{ id: 1, name: "Jane" }, { id: 2, name: "John" }]
tasks = [{ id: 1, user_id: 1, title: "Jane's task" }, { id: 2, user_id: 2, title: "John's task" }]

tasks_for_users = -> users {
  user_ids = users.map { |u| u[:id] }
  tasks.select { |t| user_ids.include?(t[:user_id]) }
}

# fetch tasks for specific users
tasks_for_users.call([{ id: 2, name: "John" }])
# [{ id: 2, user_id: 2, title: "John's task" }]
```

This example shows **the exact conceptual model of associations in ROM**. Here are important parts
to understand:

- `tasks_for_users` is an association **function** which returns all tasks matching particular users
- `user_id` is **our combine-key**, it **must be included** in the resulting data and it's used
  to merge results into nested data structures
  
Let's translate this to actual relations using the memory adapter:

``` ruby
require "rom"
require "rom/memory"

class Users < ROM::Relation[:memory]
  schema do
    attribute :id, Types::Int
    attribute :name, Types::String
    
    primary_key :id
    
    associations do
      has_many :tasks, combine_key: :user_id, override: true, view: :for_users
    end
  end
end

class Tasks < ROM::Relation[:memory]
  schema do
    attribute :id, Types::Int
    attribute :user_id, Types::Int
    attribute :title, Types::String
    
    primary_key :id
  end

  def for_users(_assoc, users)
    restrict(user_id: users.map { |u| u[:id] })
  end
end

rom = ROM.container(:memory) do |config|
  config.register_relation(Users, Tasks)
end

users = rom.relations[:users]
tasks = rom.relations[:tasks]

[{ id: 1, name: "Jane" }, { id: 2, name: "John" }].each { |tuple| users.insert(tuple) }
[{ id: 1, user_id: 1, title: "Jane's task" }, { id: 2, user_id: 2, title: "John's task" }].each { |tuple| tasks.insert(tuple) }

# load all tasks for all users
tasks.for_users(users.associations[:tasks], users).to_a
# [{:id=>1, :user_id=>1, :title=>"Jane's task"}, {:id=>2, :user_id=>2, :title=>"John's task"}]

# load tasks for particular users
tasks.for_users(users.associations[:tasks], users.restrict(name: "John")).to_a
# [{:id=>2, :user_id=>2, :title=>"John's task"}]

# when we use `combine`, our `for_users` will be called behind the scenes
puts users.restrict(name: "John").combine(:tasks).to_a
# {:id=>2, :name=>"John", :tasks=>[{:id=>2, :user_id=>2, :title=>"John's task"}]}
```

Notice that:

- Just like in our plain Ruby example, `Tasks#for_users` is a function which returns all tasks for particular
  users, and `Users` and `Tasks` relations are just collections of data
- We specified `:user_id` as our combine-key, so that data can be merged into a nested data structure via `combine` method

This model is used by all adapters, even when you don't see it, it is there. In
rom-sql default association views are generated for you, which is the whole magic
behind associations in SQL, this is why in case of SQL, we could translate our
previous example to this:

``` ruby
require "rom"

ROM.container(:sql, 'sqlite::memory') do |config|
  config.gateways[:default].create_table(:users) do
    primary_key :id
    column :name, String
  end

  config.gateways[:default].create_table(:tasks) do
    primary_key :id
    foreign_key :user_id, :users
    column :title, String
  end

  class Users < ROM::Relation[:sql]
    schema(infer: true) do
      associations do
        has_many :tasks
      end
    end
  end

  class Tasks < ROM::Relation[:sql]
    schema(infer: true)
  end
  
  config.register_relation(Users, Tasks)
end

users = rom.relations[:users]
tasks = rom.relations[:tasks]

[{ id: 1, name: "Jane" }, { id: 2, name: "John" }].each { |tuple| users.insert(tuple) }
[{ id: 1, user_id: 1, title: "Jane's task" }, { id: 2, user_id: 2, title: "John's task" }].each { |tuple| tasks.insert(tuple) }

users.combine(:tasks).to_a
# [{:id=>1, :name=>"Jane", :tasks=>[{:id=>1, :user_id=>1, :title=>"Jane's task"}]}, {:id=>2, :name=>"John", :tasks=>[{:id=>2, :user_id=>2, :title=>"John's task"}]}]

users.where(name: "John").combine(:tasks).to_a
# [{:id=>2, :name=>"John", :tasks=>[{:id=>2, :user_id=>2, :title=>"John's task"}]}]
```

## Learn more

* [api::rom::Schema](AssociationsDSL)
* [api::rom::Relation](#combine)
* [api::rom::Relation](#wrap)
