RSpec.shared_context 'users and tasks' do
  subject(:rom) { setup.finalize }

  let(:setup) { ROM.setup(memory: "memory://localhost") }

  before do
    setup.schema do
      base_relation(:users) do
        repository :memory
      end

      base_relation(:tasks) do
        repository :memory
      end
    end

    db = setup.memory

    db[:users].insert(name: "Joe", email: "joe@doe.org")
    db[:users].insert(name: "Jane", email: "jane@doe.org")

    db[:tasks].insert(name: "Joe", title: "be nice", priority: 1)
    db[:tasks].insert(name: "Joe", title: "sleep well", priority: 2)

    db[:tasks].insert(name: "Jane", title: "be cool", priority: 2)
  end
end
