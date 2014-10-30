shared_context 'users and tasks' do
  let(:rom) { ROM.setup(sqlite: SEQUEL_TEST_DB_URI) }

  before do
    conn = rom.sqlite.connection

    conn.run('create table users (name STRING, email STRING)')
    conn.run('create table tasks (name STRING, title STRING, priority INT)')

    conn[:users].insert(name: "Joe", email: "joe@doe.org")
    conn[:users].insert(name: "Jane", email: "jane@doe.org")

    conn[:tasks].insert(name: "Joe", title: "be nice", priority: 1)
    conn[:tasks].insert(name: "Joe", title: "sleep well", priority: 2)

    conn[:tasks].insert(name: "Jane", title: "be cool", priority: 2)

    rom.schema do
      base_relation(:users) do
        repository :sqlite
      end

      base_relation(:tasks) do
        repository :sqlite
      end
    end
  end

  after do
    conn = rom.sqlite.connection
    conn.drop_table? :users
    conn.drop_table? :tasks
  end
end
