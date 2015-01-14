RSpec.shared_context 'users and tasks' do
  subject(:rom) { setup.finalize }

  let(:setup) { ROM.setup("memory://localhost") }

  before do
    db = setup.default.adapter

    users = db.dataset(:users)
    tasks = db.dataset(:tasks)

    users.insert(name: "Joe", email: "joe@doe.org")
    users.insert(name: "Jane", email: "jane@doe.org")

    tasks.insert(name: "Joe", title: "be nice", priority: 1)
    tasks.insert(name: "Joe", title: "sleep well", priority: 2)

    tasks.insert(name: "Jane", title: "be cool", priority: 2)
  end
end
