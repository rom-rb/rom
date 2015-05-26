RSpec.shared_context 'users and tasks' do
  require 'rom/memory'

  subject(:rom) { setup.finalize }

  let(:setup) { ROM.setup(:memory) }

  before do
    gateway = setup.default

    users = gateway.dataset(:users)
    tasks = gateway.dataset(:tasks)

    users.insert(name: "Joe", email: "joe@doe.org")
    users.insert(name: "Jane", email: "jane@doe.org")

    tasks.insert(name: "Joe", title: "be nice", priority: 1)
    tasks.insert(name: "Joe", title: "sleep well", priority: 2)

    tasks.insert(name: "Jane", title: "be cool", priority: 2)
  end
end
