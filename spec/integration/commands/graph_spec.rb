require 'spec_helper'

describe 'Building up a command graph for nested input' do
  let(:rom) { setup.finalize }
  let(:setup) { ROM.setup(:memory) }

  before do
    setup.relation :users
    setup.relation :tasks
    setup.relation :books
    setup.relation :tags

    setup.commands(:users) do
      define(:create) do
        input Transproc(:accept_keys, [:name])
        result :one
      end
    end

    setup.commands(:books) do
      define(:create) do
        input Transproc(:accept_keys, [:title, :user])

        def execute(tuples, user)
          super(tuples.map { |t| t.merge(user: user.fetch(:name)) })
        end
      end
    end

    setup.commands(:tags) do
      define(:create) do
        input Transproc(:accept_keys, [:name, :task])

        def execute(tuples, task)
          super(tuples.map { |t| t.merge(task: task.fetch(:title)) })
        end
      end
    end
  end

  it 'creates a command graph for nested input :one result as root' do
    setup.commands(:tasks) do
      define(:create) do
        input Transproc(:accept_keys, [:title, :user])
        result :one

        def execute(tuple, user)
          super(tuple.merge(user: user.fetch(:name)))
        end
      end
    end

    input = {
      user: {
        name: 'Jane',
        task: {
          title: 'Task One',
          tags: [
            { name: 'red' }, { name: 'green' }, { name: 'blue' }
          ]
        },
        books: [
          { title: 'Book One' },
          { title: 'Book Two' }
        ]
      }
    }

    options = [
      { user: :users }, [
        :create, [
          [{ task: :tasks }, [:create, [:tags, [:create]]]],
          [:books, [:create]]
        ]
      ]
    ]

    command = rom.command(options)

    command.call(input)

    expect(rom.relation(:users)).to match_array([
      { name: 'Jane' }
    ])

    expect(rom.relation(:tasks)).to match_array([
      { title: 'Task One', user: 'Jane' }
    ])

    expect(rom.relation(:books)).to match_array([
      { title: 'Book One', user: 'Jane' },
      { title: 'Book Two', user: 'Jane' }
    ])

    expect(rom.relation(:tags)).to match_array([
      { name: 'red', task: 'Task One' },
      { name: 'green', task: 'Task One' },
      { name: 'blue', task: 'Task One' }
    ])
  end

  it 'creates a command graph for nested input with :many results as root' do
    setup.commands(:tasks) do
      define(:create) do
        input Transproc(:accept_keys, [:title, :user])

        def execute(tuples, user)
          super(tuples.map { |t| t.merge(user: user.fetch(:name)) })
        end
      end
    end

    input = {
      user: {
        name: 'Jane',
        tasks: [
          {
            title: 'Task One',
            tags: [{ name: 'red' }, { name: 'green' }]
          },
          {
            title: 'Task Two',
            tags: [{ name: 'blue' }]
          }
        ]
      }
    }

    options = [
      { user: :users }, [
        :create, [
          [:tasks, [:create, [:tags, [:create]]]],
        ]
      ]
    ]

    command = rom.command(options)

    command.call(input)

    expect(rom.relation(:users)).to match_array([
      { name: 'Jane' }
    ])

    expect(rom.relation(:tasks)).to match_array([
      { title: 'Task One', user: 'Jane' },
      { title: 'Task Two', user: 'Jane' }
    ])

    expect(rom.relation(:tags)).to match_array([
      { name: 'red', task: 'Task One' },
      { name: 'green', task: 'Task One' },
      { name: 'blue', task: 'Task Two' }
    ])
  end

  it 'works with auto-mapping' do
    setup.mappers do
      define(:users) do
        register_as :entity
        reject_keys true

        model name: 'Test::User'

        attribute :name

        combine :task, type: :hash, on: { name: :user } do
          model name: 'Test::Task'
          attribute :title
        end
      end
    end

    setup.commands(:tasks) do
      define(:create) do
        input Transproc(:accept_keys, [:title, :user])
        result :one

        def execute(tuple, user)
          super(tuple.merge(user: user.fetch(:name)))
        end
      end
    end

    input = { user: { name: 'Jane', task: { title: 'Task One' } } }

    command = rom.command([
      { user: :users }, [:create, [{ task: :tasks }, [:create]]]
    ]).as(:entity)

    result = command.call(input).first

    expect(result).to be_instance_of(Test::User)
    expect(result.task).to be_instance_of(Test::Task)
  end
end
