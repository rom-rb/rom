require 'spec_helper'

describe ROM::Relation::Lazy, '#combine' do
  include_context 'users and tasks'

  before do
    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end
    end

    setup.relation(:tasks) do
      def for_users(users)
        names = users.map { |user| user[:name] }
        restrict { |task| names.include?(task[:name]) }
      end
    end

    setup.relation(:tags) do
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
    end

    setup.gateways[:default].dataset(:tags).insert(task: 'be cool', name: 'red')
    setup.gateways[:default].dataset(:tags).insert(task: 'be cool', name: 'green')
  end

  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }
  let(:tags) { rom.relation(:tags) }

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
      users.combine(tasks >> proc {})
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

    user_with_tasks_and_tags = users.by_name('Jane')
      .combine(tasks.for_users, tags.for_users)

    result = user_with_tasks_and_tags >> map_user_with_tasks_and_tags

    expect(result).to match_array(expected)
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

    user_with_tasks_and_tags = users.by_name('Jane')
      .combine(tasks.for_users).combine(tags.for_users)

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

    user_with_tasks = users.by_name('Jane')
      .combine(tasks.for_users.combine(tags.for_tasks))

    result = user_with_tasks >> map_user_with_tasks

    expect(result).to match_array(expected)
  end
end
