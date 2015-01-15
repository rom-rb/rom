RSpec.shared_context 'users and tasks' do
  require 'rom/adapter/memory'

  subject(:rom) { setup.finalize }

  let(:setup) { ROM.setup("memory://localhost") }

  before do
    repository = setup.default

    users = repository.dataset(:users)
    tasks = repository.dataset(:tasks)

    users.insert(name: "Joe", email: "joe@doe.org")
    users.insert(name: "Jane", email: "jane@doe.org")

    tasks.insert(name: "Joe", title: "be nice", priority: 1)
    tasks.insert(name: "Joe", title: "sleep well", priority: 2)

    tasks.insert(name: "Jane", title: "be cool", priority: 2)
  end
end
