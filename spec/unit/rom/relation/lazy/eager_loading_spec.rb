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
  end

  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }

  it 'works' do
    expected = [
      {
        name: 'Jane', email: 'jane@doe.org', tasks: [
          { name: 'Jane', title: 'be cool', priority: 2 }
        ]
      }
    ]

    mapper = proc { |users, tasks|
      users.map { |user|
        user.merge(tasks: tasks.select { |task| task[:name] == user[:name] })
      }
    }

    user_with_tasks = users.by_name('Jane').eager_load(tasks.for_users) >> mapper

    expect(user_with_tasks).to match_array(expected)
  end
end
