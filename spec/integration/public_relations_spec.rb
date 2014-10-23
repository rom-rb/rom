require 'spec_helper'

describe 'Defining public relations' do
  let(:rom) { ROM.setup(sqlite: SEQUEL_TEST_DB_URI) }

  before do
    conn = rom.sqlite.connection

    conn.run('create table users (name STRING, email STRING)')
    conn.run('create table tasks (name STRING, title STRING, priority INT)')

    conn[:users].insert(name: "Joe", email: "joe@doe.org")
    conn[:users].insert(name: "Jane", email: "jane@doe.org")
    conn[:tasks].insert(name: "Joe", title: "be nice", priority: 1)
    conn[:tasks].insert(name: "Jane", title: "be cool", priority: 2)

    rom.schema do
      base_relation(:users) do
        repository :sqlite

        attribute :name, String
        attribute :email, String
      end

      base_relation(:tasks) do
        repository :sqlite

        attribute :title, String
        attribute :priority, Integer
      end
    end
  end

  after do
    conn = rom.sqlite.connection
    conn.drop_table? :users
    conn.drop_table? :tasks
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

      users do
        def with_tasks
          natural_join(tasks)
        end
      end
    end

    tasks = rom.relations.tasks

    expect(tasks.class.name).to eql("ROM::Relation[Tasks]")
    expect(tasks.high_priority.inspect).to include("#<ROM::Relation[Tasks]")

    expect(tasks.high_priority.by_title("be nice").to_a).to eql([name: "Joe", title: "be nice", priority: 1])
    expect(tasks.by_title("be cool").to_a).to eql([name: "Jane", title: "be cool", priority: 2])

    users = rom.relations.users

    expect(users.with_tasks.to_a).to eql(
      [{ name: "Joe", email: "joe@doe.org", title: "be nice", priority: 1 },
       { name: "Jane", email: "jane@doe.org", title: "be cool", priority: 2 }]
    )
  end
end
