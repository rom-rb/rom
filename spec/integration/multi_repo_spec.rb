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
        attribute :user_id
        attribute :name
      end

      base_relation :tasks do
        repository :right
        attribute :user_id
        attribute :title
      end

      base_relation :users_and_tasks do
        repository :main

        attribute :user_id
        attribute :name
        attribute :title
      end
    end

    setup.relation(:users)
    setup.relation(:tasks)

    setup.relation(:users_and_tasks) do
      include ROM::RA

      def all
        join(users, tasks)
      end
    end

    setup.mappers do
      define(:users_and_tasks) do
        group tasks: [:title]
      end
    end

    rom = setup.finalize

    rom.left.users << { user_id: 1, name: 'Jane' }
    rom.right.tasks << { user_id: 1, title: 'Have fun' }

    expect(rom.read(:users_and_tasks).all.to_a).to eql([
      { user_id: 1, name: 'Jane', tasks: [{ title: 'Have fun' }] }
    ])
  end
end
