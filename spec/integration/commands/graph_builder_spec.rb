require 'spec_helper'

describe 'Building up a command graph from nested input' do
  let(:rom) { setup.finalize }
  let(:setup) { ROM.setup(:memory) }

  before do
    setup.relation :users
    setup.relation :tasks

    setup.commands(:users) do
      define(:create) do
        input Transproc(:accept_keys, [:name])
        result :one
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
  end

  it 'creates a command graph for nested input' do
    input = {
      user: {
        name: 'Jane',
        task: { title: 'Task One' }
      }
    }

    options = [
      { user: :users }, [:create, [
        { task: :tasks }, [:create]]
      ]
    ]

    command = rom.command(options, input)

    command.call

    expect(rom.relation(:users)).to match_array([
      { name: 'Jane' }
    ])

    expect(rom.relation(:tasks)).to match_array([
      { title: 'Task One', user: 'Jane' }
    ])
  end
end
