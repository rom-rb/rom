require 'spec_helper'

describe ROM::Commands::Graph do
  let(:rom) { setup.finalize }
  let(:setup) { ROM.setup(:memory) }

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

  it 'works' do
    create_user = rom.command(:users).create
    create_task = rom.command(:tasks).create
    create_tags = rom.command(:tags).create

    user = { name: 'Jane' }
    task = { title: 'One' }
    tags = [{ name: 'red' }, { name: 'green' }, { name: 'blue' }]

    command = create_user.with(user)
      .combine(create_task.with(task).combine(create_tags.with(tags)))

    result = command.call

    expect(result).to match_array([
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

    expect(rom.relation(:users)).to match_array([{ name: 'Jane' }])

    expect(rom.relation(:tasks)).to match_array([{ user: 'Jane', title: 'One' }])

    expect(rom.relation(:tags)).to match_array([
      { task: 'One', name: 'red' },
      { task: 'One', name: 'green' },
      { task: 'One', name: 'blue' }
    ])
  end
end
