require 'spec_helper'

RSpec.describe ROM::Relation, '#combine' do
  include_context 'gateway only'
  include_context 'users and tasks'

  let(:tags_dataset) { gateway.dataset(:tags) }

  let(:users_relation) do
    Class.new(ROM::Memory::Relation) do
      def by_name(name)
        restrict(name: name)
      end
    end.new(users_dataset)
  end

  let(:tasks_relation) do
    Class.new(ROM::Memory::Relation) do
      def for_users(users)
        names = users.map { |user| user[:name] }
        restrict { |task| names.include?(task[:name]) }
      end
    end.new(tasks_dataset)
  end

  let(:tags_relation) do
    Class.new(ROM::Memory::Relation) do
      attr_accessor :tasks
      forward :map

      def for_tasks(tasks)
        titles = tasks.map { |task| task[:title] }
        restrict { |tag| titles.include?(tag[:task]) }
      end

      def for_users(users)
        user_tasks = tasks.for_users(users)

        for_tasks(user_tasks).map { |tag|
          tag.merge(user: user_tasks.detect { |task|
            task[:title] == tag[:task]
          } [:name])
        }
      end
    end.new(tags_dataset).tap { |r| r.tasks = tasks_relation }
  end

  before do
    tags_dataset.insert(task: 'be cool', name: 'red')
    tags_dataset.insert(task: 'be cool', name: 'green')
  end

  let(:map_users) {
    proc { |users, tasks|
      users.map { |user|
        user.merge(tasks: tasks.select { |task| task[:name] == user[:name] })
      }
    }
  }

  let(:map_tasks) {
    proc { |(tasks, children)|
      tags = children.first

      tasks.map { |task|
        task.merge(tags: tags.select { |tag| tag[:task] == task[:title] })
      }
    }
  }

  let(:map_user_with_tasks_and_tags) {
    proc { |users, (tasks, tags)|
      users.map { |user|
        user_tasks = tasks.select { |task| task[:name] == user[:name] }

        user_tags = tasks.flat_map { |task|
          tags.select { |tag| tag[:task] == task[:title] }
        }

        user.merge(
          tasks: user_tasks,
          tags: user_tags
        )
      }
    }
  }

  let(:map_user_with_tasks) {
    proc { |users, children|
      map_users[users, map_tasks[children.first]]
    }
  }

  it 'raises error when composite relation is passed as a node' do
    expect {
      users_relation.combine(tasks_relation >> proc {})
    }.to raise_error(ROM::UnsupportedRelationError)
  end

  it 'supports more than one eagerly-loaded relation' do
    expected = [
      {
        name: 'Jane',
        email: 'jane@doe.org',
        tasks: [
          { name: 'Jane', title: 'be cool', priority: 2 }
        ],
        tags: [
          { task: 'be cool', name: 'red', user: 'Jane' },
          { task: 'be cool', name: 'green', user: 'Jane' }
        ]
      }
    ]

    user_with_tasks_and_tags = users_relation.by_name('Jane')
      .combine(tasks_relation.for_users, tags_relation.for_users)

    result = user_with_tasks_and_tags >> map_user_with_tasks_and_tags

    expect(result.to_a).to eql(expected)
  end

  it 'supports more than one eagerly-loaded relation via chaining' do
    expected = [
      {
        name: 'Jane',
        email: 'jane@doe.org',
        tasks: [
          { name: 'Jane', title: 'be cool', priority: 2 }
        ],
        tags: [
          { task: 'be cool', name: 'red', user: 'Jane' },
          { task: 'be cool', name: 'green', user: 'Jane' }
        ]
      }
    ]

    user_with_tasks_and_tags = users_relation.by_name('Jane')
      .combine(tasks_relation.for_users).combine(tags_relation.for_users)

    result = user_with_tasks_and_tags >> map_user_with_tasks_and_tags

    expect(result).to match_array(expected)
  end

  it 'supports nested eager-loading' do
    expected = [
      {
        name: 'Jane', email: 'jane@doe.org', tasks: [
          { name: 'Jane', title: 'be cool', priority: 2, tags: [
            { task: 'be cool', name: 'red' },
            { task: 'be cool', name: 'green' }
          ] }
        ]
      }
    ]

    user_with_tasks = users_relation.by_name('Jane')
      .combine(tasks_relation.for_users.combine(tags_relation.for_tasks))

    result = user_with_tasks >> map_user_with_tasks

    expect(result).to match_array(expected)
  end
end
