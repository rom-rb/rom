require 'spec_helper'

describe 'Using in-memory adapter for cross-repo access' do
  it 'works' do
    setup = ROM.setup(
      left: 'memory://localhost/users',
      right: 'memory://localhost/tasks',
      main: 'memory://localhost/main'
    )

    setup.schema do
      base_relation :users do
        repository :left
      end

      base_relation :tasks do
        repository :right
      end

      base_relation :users_and_tasks do
        repository :main
      end
    end

    setup.relation(:users) do
      def by_name(name)
        restrict(name: name)
      end
    end

    setup.relation(:tasks)

    setup.relation(:users_and_tasks) do
      def by_user(name)
        join(users.by_name(name), tasks)
      end
    end

    setup.mappers do
      define(:users_and_tasks) do
        group tasks: [:title]
      end
    end

    rom = setup.finalize

    rom.left.users << { user_id: 1, name: 'Joe' }
    rom.left.users << { user_id: 2, name: 'Jane' }
    rom.right.tasks << { user_id: 1, title: 'Have fun' }
    rom.right.tasks << { user_id: 2, title: 'Have fun' }

    expect(rom.read(:users_and_tasks).by_user('Jane').to_a).to eql([
      { user_id: 2, name: 'Jane', tasks: [{ title: 'Have fun' }] }
    ])
  end
end
