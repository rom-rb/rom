require "spec_helper"
require "rom/ra/operation/join"

describe 'Join operation between two repositories' do
  let(:rom) { ROM.setup(sqlite: SEQUEL_TEST_DB_URI, memory: "memory://test") }

  before do
    seed(rom.sqlite.connection)
  end

  after do
    deseed(rom.sqlite.connection)
  end

  specify 'defining a joined relation' do
    rom.schema do
      base_relation(:users) do
        repository :sqlite
      end

      base_relation(:tasks) do
        repository :memory

        attribute :name
        attribute :title
      end
    end

    rom.relations do
      users do
        def with_tasks
          RA.join(users, tasks)
        end
      end
    end

    rom.schema.tasks << { name: 'Joe', title: 'Be happy' }

    users = rom.relations.users

    expect(users.with_tasks.to_a).to eql(
      [{ id: 2, name: 'Joe', title: 'Be happy' }]
    )
  end

end
