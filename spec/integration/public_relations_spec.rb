require 'spec_helper'

describe 'Defining public relations' do
  let(:rom) { ROM.setup(sqlite: "sqlite::memory") }

  before do
    conn = rom.sqlite.connection

    conn.run('create table tasks (title STRING, priority INT)')

    conn[:tasks].insert(title: "be nice", priority: 1)
    conn[:tasks].insert(title: "be cool", priority: 2)

    rom.schema do
      base_relation(:tasks) do
        repository :sqlite

        attribute :title, String
        attribute :priority, Integer
        attribute :created_at, DateTime
      end
    end
  end

  it 'allows to expose chainable relations' do
    rom.relations do
      tasks do
        def high_priority
          where { priority < 2 }
        end

        def by_title(title)
          where(title: title)
        end
      end
    end

    tasks = rom.relations[:tasks].high_priority.by_title("be nice").to_a

    expect(tasks).to eql([title: "be nice", priority: 1])
  end
end
