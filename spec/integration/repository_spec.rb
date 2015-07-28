RSpec.describe 'ROM repository' do
  include_context 'database'

  subject(:repo) { repo_class.new(rom) }

  let(:repo_class) do
    Class.new(ROM::Repository::Base) do
      relations :users, :tasks

      def all_users
        users.select(:id, :name).order(:name, :id)
      end

      def users_with_tasks
        users.combine(tasks.for_users)
      end
    end
  end

  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }

  let(:user_struct) { repo.users.mapper.model }
  let(:task_struct) { repo.tasks.mapper.model }

  let(:user_with_tasks_struct) { repo.users_with_tasks.mapper.model }

  let(:jane) { user_struct.new(id: 1, name: 'Jane') }
  let(:jane_with_tasks) { user_with_tasks_struct.new(id: 1, name: 'Jane', tasks: [jane_task]) }
  let(:jane_task) { task_struct.new(id: 2, user_id: 1, title: 'Jane Task') }

  let(:joe) { user_struct.new(id: 2, name: 'Joe') }
  let(:joe_with_tasks) { user_with_tasks_struct.new(id: 2, name: 'Joe', tasks: [joe_task]) }
  let(:joe_task) { task_struct.new(id: 1, user_id: 2, title: 'Joe Task') }

  before do
    setup.relation(:tasks) do
      def for_users(users)
        where(user_id: users.map { |u| u[:id] })
      end
    end
  end

  it 'loads a single relation' do
    conn[:users].insert name: 'Jane'
    conn[:users].insert name: 'Joe'

    expect(repo.all_users.to_a).to eql([jane, joe])
  end

  it 'loads a combined relation' do
    jane_id = conn[:users].insert name: 'Jane'
    joe_id = conn[:users].insert name: 'Joe'

    conn[:tasks].insert user_id: joe_id, title: 'Joe Task'
    conn[:tasks].insert user_id: jane_id, title: 'Jane Task'

    expect(repo.users_with_tasks.to_a).to eql([jane_with_tasks, joe_with_tasks])
  end
end
