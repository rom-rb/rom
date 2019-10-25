---
chapter: Repositories
title: Writing Aggregates
---

Repositories provide a command builder interface which you can use to construct complex commands that can persist nested data, which reflect aggregate structures.

^WARNING
This API is limited to `Create` commands only. Use [changesets](/learn/changeset/%{version}) if you need more flexibility and control.
^

## has_many example

Let's say we have `:users` with `:tasks` and we'd like to persist a nested data structure which represents this association.

``` ruby
require 'rom-repository'

rom = ROM.container(:sql, 'sqlite::memory') do |config|
  config.default.create_table(:users) do
    primary_key :id
    column :name, String, null: false
    column :email, String, null: false
  end

  config.default.create_table(:tasks) do
    primary_key :id
    foreign_key :user_id, :users
    column :title, String, null: false
  end

  config.relation(:users) do
    schema(infer: true) do
      associations do
        has_many :tasks
      end
    end
  end

  config.relation(:tasks) do
    schema(infer: true) do
      associations do
        belongs_to :user
      end
    end
  end
end
```

Once we establish canonical associations for our relations, repositories will know how to prepare commands for persisting nested data.

Let's define a repository which exposes an interface for persisting a new user along with associated tasks:

``` ruby
class UserRepo < ROM::Repository[:users]
  def create_with_tasks(user)
    users.combine(:tasks).command(:create).call(user)
  end
end

user_repo = UserRepo.new(rom)

user_repo.create_with_tasks(
  name: 'Jane',
  email: 'jane@doe.org',
  tasks: [{ title: 'Task 1' }, { title: 'Task 2' }]
)
# => #<ROM::Struct[User] id=1 name="Jane" email="jane@doe.org" tasks=[#<ROM::Struct[Task] id=1 user_id=1 title="Task 1">, #<ROM::Struct[Task] id=2 user_id=1 title="Task 2">]>
```
