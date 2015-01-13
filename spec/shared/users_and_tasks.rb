RSpec.shared_context 'users and tasks' do
  subject(:rom) { setup.finalize }

  let(:setup) { ROM.setup("memory://localhost") }

  before do
    db = setup.default.adapter

    db.dataset(:users)
    db.dataset(:tasks)

    db[:users].insert(name: "Joe", email: "joe@doe.org")
    db[:users].insert(name: "Jane", email: "jane@doe.org")

    db[:tasks].insert(name: "Joe", title: "be nice", priority: 1)
    db[:tasks].insert(name: "Joe", title: "sleep well", priority: 2)

    db[:tasks].insert(name: "Jane", title: "be cool", priority: 2)
  end
end
