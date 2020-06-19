---
chapter: Repositories
title: Reading Simple Objects
---

It's best to create multiple Repository classes that each focus on a segment of the data. One rough guideline is to make a repository for each concept within your app:

```ruby
# Assuming a database with tables 'users' and 'projects'
rom = ROM.container(:sql, 'sqlite::memory') do |config|
  config.relation(:users) do
    schema(infer: true)
    auto_struct true
  end
  config.relation(:projects) do
    schema(infer: true)
    auto_struct true
  end
end

# Perhaps one Repo to handle users
class UserRepo < ROM::Repository[:users]
end

# Another repository could handle the projects
class ProjectRepo < ROM::Repository[:projects]
end

user_repo = UserRepo.new(rom)
project_repo = ProjectRepo.new(rom)
```

## Repository Interface

While defining a repository, you will also define its interface for domain-specific queries. These are called **selector methods**.

They use the querying methods provided by the relations to accomplish their task. For example, the `rom-sql` adapter provides methods like `Relation#where`.

```ruby
class UserRepo < ROM::Repository[:users]
  # find all users with the given attributes
  def query(conditions)
    users.where(conditions)
  end

  # collect a list of all user ids
  def ids
    users.pluck(:id)
  end
end
```

Read your adapter's documentation to see the full listing of its Relation methods.

## Full Example

This short example demonstrates using selector methods, `#one`, and `#to_a`.

```ruby
require 'rom-repository'

rom = ROM.container(:sql, 'sqlite::memory') do |config|
  config.default.connection.create_table(:users) do
    primary_key :id
    column :name, String, null: false
    column :email, String, null: false
  end

  config.relation(:users) do
    schema(infer: true)
  end
end

class UserRepo < ROM::Repository[:users]
  def query(conditions)
    users.where(conditions).to_a
  end

  def by_id(id)
    users.by_pk(id).one!
  end

  # ... etc
end

user_repo = UserRepo.new(rom)
```

^INFO
Notice that `users.where` and `users.by_pk` are SQL-specific interfaces that **should not leak into your application domain layer**, that's why we hide them behind our own repository interface.
^

And then in our app we can use the selector methods:

```ruby
# assuming that there is already data present

user_repo.query(first_name: 'Malcolm', last_name: 'Reynolds')
#=> [ROM::Struct[User] , ROM::Struct[User], ...]

user_repo.by_id(1)
#=> {id: 1, first_name: 'Malcolm', last_name: 'Reynolds'}
```

## Next

Now we can read simple structs. Next, learn how to [read complex, aggregate data](/learn/repository/%{version}/reading-aggregates).
