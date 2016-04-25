RSpec.shared_context 'seeds' do
  before do
    jane_id = conn[:users].insert name: 'Jane'
    joe_id = conn[:users].insert name: 'Joe'

    conn[:tasks].insert user_id: joe_id, title: 'Joe Task'
    task_id = conn[:tasks].insert user_id: jane_id, title: 'Jane Task'

    conn[:tags].insert task_id: task_id, name: 'red'

    conn[:posts].insert author_id: joe_id, title: 'Hello From Joe', body: 'Joe Post'
    conn[:posts].insert author_id: jane_id, title: 'Hello From Jane', body: 'Jane Post'
  end
end
