require 'spec_helper'

describe 'Eager loading' do
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
      def for_tasks(tasks)
        titles = tasks.map { |task| task[:title] }
        restrict { |tag| titles.include?(tag[:task]) }
      end
    end

    setup.repositories[:default].dataset(:tags).insert(task: 'be cool', name: 'red')
    setup.repositories[:default].dataset(:tags).insert(task: 'be cool', name: 'green')
  end

  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }
  let(:tags) { rom.relation(:tags) }

  it 'works' do
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

    map_users = proc { |users, tasks|
      users.map { |user|
        user.merge(tasks: tasks.select { |task| task[:name] == user[:name] })
      }
    }

    map_tasks = proc { |tasks, tags|
      tasks.map { |task|
        task.merge(tags: tags.select { |tag| tag[:task] == task[:title] })
      }
    }

    mapper = proc { |users, (tasks, tags)|
      map_users[users, map_tasks[tasks, tags]]
    }

    user_with_tasks = users.by_name('Jane')
      .eager_load(tasks.for_users.eager_load(tags.for_tasks))

    expect(user_with_tasks >> mapper).to match_array(expected)
  end
end
