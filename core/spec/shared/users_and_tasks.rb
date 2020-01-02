RSpec.shared_context 'users and tasks' do
  before do
    users_dataset.insert(name: 'Joe', email: 'joe@doe.org')
    users_dataset.insert(name: 'Jane', email: 'jane@doe.org')

    tasks_dataset.insert(name: 'Joe', title: 'be nice', priority: 1)
    tasks_dataset.insert(name: 'Joe', title: 'sleep well', priority: 2)
    tasks_dataset.insert(name: 'Jane', title: 'be cool', priority: 2)
  end
end
