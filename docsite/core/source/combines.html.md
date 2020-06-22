---
chapter: Core
title: Combines
---

$TOC
  1. [Basic Combine](#basic-combine)
  2. [Nested Combine](#nested-combine)
  3. [Adjusted Combine](#adjusted-combine)
$TOC

Combines are a feature provided by [relations](/learn/core/%{version}/relations)
that take advantage of [associations](/learn/core/%{version}/associations)
between relations to reliably merge (aka combine) and construct complex nested
data structures.

In cases where there is a need to load some data along with its dependent nested
data then <mark>Relation#combine</mark> is the tool to reach for. It might be a
bit of a paradigm shift, but it's important to realize ROM will **never** load
associated data unless it is explicitly told to do so.

This idea is in stark contrast with other ORMs such as Active Record for Rails
which offer lazy loading by default. Since composing data is so quick and easy
lazy loading is not needed preventing a whole class of issues such as N+1
query performance problems.

^INFO
  Before you can combine relations an association has to be configured in
  the relations' schema. See [associations](/learn/core/%{version}/associations)
  for more details.
^

## Basic Combine

Suppose we have a set of relations `:projects`, `:project_tasks`, `:users` and a
dataset defined as such:

```ruby
# Dataset representation

# purely a visual representation of the data
# as it would sit in the database
users = [
  {id: 1, username: 'briang'},
  {id: 2, username: 'mary_matrix'}
]

projects = [
  {id: 1, user_id: 1, name: 'Kinda Lame Project'},
  {id: 2, user_id: 2, name: 'Super Important Project'},
  {id: 3, user_id: 1, name: 'Secret Mega Project'}
]

project_tasks = [
  {id: 1, project_id: 1, description: 'Project 1, Task 1'},
  {id: 2, project_id: 1, description: 'Project 1, Task 2'},
  {id: 3, project_id: 2, description: 'Project 2, Task 1'},
  {id: 4, project_id: 2, description: 'Project 2, Task 2'},
  {id: 5, project_id: 3, description: 'Project 3, Task 1'},
]

# Relations
class Projects < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      has_many   :project_tasks
      belongs_to :users, as: :user
    end
  end
end

class ProjectTasks < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      belongs_to :projects, as: :project
    end
  end
end

class Users < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      has_many :projects
    end
  end

  # rom-sql by default provides a relation view called 'by_pk(id)'
  # which does the same thing as this however for clarities sake
  # we've included this relation view
  def by_id(id)
    where(id: id)
  end
end
```

To load a specific user with all of their projects is pretty easy in ROM:

```ruby
# Example: 1
users_relation.by_id(2).one
# => {:id=>2, :username=>"mary_matrix"}

# Example: 2
users_relation.combine(:projects).by_id(2).one
# => {:id=>2,
#     :username=>"mary_matrix",
#     :projects=>[{:id=>2, :user_id=>2, :name=>"Super Important Project"}]}
```

As you can see from the output in the first example, only the data available in the user
relation is available where as in the second example the user with their projects are
included in the output. It's important to note that while the project records are
in the output, no project task records are. This again is because ROM only loads the data
you've requested. So what if you want to load a user with all of their projects and tasks?

### Nested Combine

Using the same relations as defined in the [Basic Combine](#basic-combine) section we
can combine as many relations as we wish at any arbitrary depth:

```ruby
user_relation.by_id(2).combine(projects: :project_tasks).one

# => {:id=>2,
#     :username=>"mary_matrix",
#     :projects=>[
#       {
#         :id=>2,
#         :user_id=>2,
#         :name=>"Super Important Project",
#         :project_tasks=>[
#           {
#             :id=>3,
#             :project_id=>2,
#             :description=>"Project 2, Task 1"
#           },
#           {
#            :id=>4,
#            :project_id=>2,
#            :description=>"Project 2,Task 2"
#           }
#         ]
#       }
#     ]
#   }
```

Nested combines allow developers to create properly normalized data sets and then query them with
ease. Since `Relation#combine` accepts a hash we could combine many more relations if we needed.

For instance, say every project and project task required a 'reviewer' to be tracked on
the record; something like this:

```ruby
class Projects < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      has_many   :project_tasks
      belongs_to :users, as: :user
      belongs_to :users, as: :reviewed_by
    end
  end
end

class ProjectTasks < ROM::Relation[:sql]
  schema(infer: true) do
    associations do
      belongs_to :projects, as: :project
      belongs_to :users, as: :reviewed_by
    end
  end
end
```

We can then combine a set of nested relations by passing combine a `Hash` made of
sub hashes or arrays matching the nested structure of our relations. As an example:

```ruby

user_relation
  .by_id(2)
  .combine(projects: [{project_tasks: :reviewed_by}, :reviewed_by])
  .one

# {:id=>2,
#  :username=>"mary_matrix",
#  :projects=>
#   [{:id=>2,
#     :user_id=>2,
#     :reviewed_by_id=>1,
#     :name=>"Super Important Project",
#     :project_tasks=>
#      [{:id=>3,
#        :project_id=>2,
#        :reviewed_by_id=>1,
#        :description=>"Project 2, Task 1",
#        :reviewed_by=>{:id=>1, :username=>"briang"}},
#       {:id=>4,
#        :project_id=>2,
#        :reviewed_by_id=>1,
#        :description=>"Project 2, Task 2",
#        :reviewed_by=>{:id=>1, :username=>"briang"}}],
#     :reviewed_by=>{:id=>2, :username=>"mary_matrix"}}]}
```

Admittedly the combine can become a bit messy when dealing with nested
relations, however if the nested combine becomes too unwieldy it might suggest
you're using the relation to select too much multi-purpose data. Our advice
would be to reevaluate the purpose of the final entity and see if it can be
broken into smaller, easily retrieved entities.

### Adjusted Combine

Sometimes you only want a subset of the data in a nested relation or you
want to restrict a nested relation to only return certain matching data.

Luckily with ROM that can easily be accomplished with the use of `Relation#node`, or
more accurately `Relation::Combined#node`. The node method allows for the adjustment
of all the relations in the composition.

```ruby
user_relation
  .by_id(1)
  .combine(projects: :project_tasks)
  .node(projects: :project_tasks) {|project_tasks_relation|
    project_tasks_relation.where(description: 'Project 1, Task 2')
  }
  .one

# {:id=>1,
#   :username=>"briang",
#   :projects=>
#    [{:id=>1,
#      :user_id=>1,
#      :reviewed_by_id=>2,
#      :name=>"Kinda Lame Project",
#      :project_tasks=>
#       [{:id=>2,
#         :project_id=>1,
#         :reviewed_by_id=>2,
#         :description=>"Project 1, Task 2"}]},   <-- LOOK HERE
#     {:id=>3,
#      :user_id=>1,
#      :reviewed_by_id=>2,
#      :name=>"Secret Mega Project",
#      :project_tasks=>[]}]}
```

Here we can see that a restriction was applied to project tasks and only the task matching
our restriction was loaded.

To grab only a subset of the data associated with a nested relation we can adjust the
projection by using `select`:

```ruby
user_relation
  .by_id(2)
  .combine(projects: :project_tasks)
  .node(projects: :project_tasks) {|project_tasks_relation|
    project_tasks_relation.select(:id, :project_id)
  }
  .one

#  {:id=>2,
#   :username=>"mary_matrix",
#   :projects=>
#    [{:id=>2,
#      :user_id=>2,
#      :reviewed_by_id=>1,
#      :name=>"Super Important Project",
#      :project_tasks=>[{:id=>3, :project_id=>2}, {:id=>4, :project_id=>2}]}]}
```

^INFO
  When adjusting combines, the order of `#combine` and `#node` is important.
  `#node` must come after `#combine` in the call chain otherwise
  the *block* will be ignored and the adjustment will fail
^

## Learn More

You can learn more about `#node` and its method signatures:

- [api::rom::Relation/Combined](#node)

