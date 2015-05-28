require 'spec_helper'

describe ROM::Commands::Graph do
  subject(:command) do
    create_user.with(user)
      .combine(create_task.with(task)
        .combine(create_tags.with(tags)))
  end

  let(:rom) { setup.finalize }
  let(:setup) { ROM.setup(:memory) }

  let(:create_user) { rom.command(:users).create }
  let(:create_task) { rom.command(:tasks).create }
  let(:create_tags) { rom.command(:tags).create }

  let(:user) { { name: 'Jane' } }
  let(:task) { { title: 'One' } }
  let(:tags) { [{ name: 'red' }, { name: 'green' }, { name: 'blue' }] }

  before do
    setup.relation(:users)
    setup.relation(:tasks)
    setup.relation(:tags)

    setup.commands(:users) do
      define(:create) do
        result :one
      end
    end

    setup.commands(:tasks) do
      define(:create) do
        result :one

        def execute(task, user)
          super(task.merge(user: user[:name]))
        end
      end
    end

    setup.commands(:tags) do
      define(:create) do
        def execute(tags, task)
          super(tags.map { |t| t.merge(task: task[:title]) })
        end
      end
    end
  end

  describe '#call' do
    it 'returns nested results' do
      expect(command.call).to match_array([
        { name: 'Jane' },
        [
          { user: 'Jane', title: 'One' },
          [
            { task: 'One', name: 'red' },
            { task: 'One', name: 'green' },
            { task: 'One', name: 'blue' }
          ]
        ]
      ])
    end

    it 'inserts root' do
      command.call
      expect(rom.relation(:users)).to match_array([{ name: 'Jane' }])
    end

    it 'inserts root nodes' do
      command.call
      expect(rom.relation(:tasks)).to match_array([{ user: 'Jane', title: 'One' }])
    end

    it 'inserts nested graph nodes' do
      command.call
      expect(rom.relation(:tags)).to match_array([
        { task: 'One', name: 'red' },
        { task: 'One', name: 'green' },
        { task: 'One', name: 'blue' }
      ])
    end
  end
end
