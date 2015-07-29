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
        combine(users, many: { all_tasks: tasks })
      end

      def users_with_task
        combine(users, one: { task: tasks })
      end

      def users_with_task_by_title(title)
        combine(users, one: { task: tasks.where(title: title) })
      end
    end
  end

  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }

  let(:user_struct) { repo.users.mapper.model }
  let(:task_struct) { repo.tasks.mapper.model }

  let(:user_with_tasks_struct) { repo.users_with_tasks.mapper.model }
  let(:user_with_task_struct) { repo.users_with_task.mapper.model }

  let(:jane) { user_struct.new(id: 1, name: 'Jane') }
  let(:jane_with_tasks) { user_with_tasks_struct.new(id: 1, name: 'Jane', all_tasks: [jane_task]) }
  let(:jane_with_task) { user_with_task_struct.new(id: 1, name: 'Jane', task: jane_task) }
  let(:jane_without_task) { user_with_task_struct.new(id: 1, name: 'Jane', task: nil) }
  let(:jane_task) { task_struct.new(id: 2, user_id: 1, title: 'Jane Task') }

  let(:joe) { user_struct.new(id: 2, name: 'Joe') }
  let(:joe_with_tasks) { user_with_tasks_struct.new(id: 2, name: 'Joe', all_tasks: [joe_task]) }
  let(:joe_with_task) { user_with_task_struct.new(id: 2, name: 'Joe', task: joe_task) }
  let(:joe_task) { task_struct.new(id: 1, user_id: 2, title: 'Joe Task') }

  it 'loads a single relation' do
    conn[:users].insert name: 'Jane'
    conn[:users].insert name: 'Joe'

    expect(repo.all_users.to_a).to eql([jane, joe])
  end

  it 'loads a combined relation with many children' do
    jane_id = conn[:users].insert name: 'Jane'
    joe_id = conn[:users].insert name: 'Joe'

    conn[:tasks].insert user_id: joe_id, title: 'Joe Task'
    conn[:tasks].insert user_id: jane_id, title: 'Jane Task'

    expect(repo.users_with_tasks.to_a).to eql([jane_with_tasks, joe_with_tasks])
  end

  it 'loads a combined relation with one child' do
    jane_id = conn[:users].insert name: 'Jane'
    joe_id = conn[:users].insert name: 'Joe'

    conn[:tasks].insert user_id: joe_id, title: 'Joe Task'
    conn[:tasks].insert user_id: jane_id, title: 'Jane Task'

    expect(repo.users_with_task.to_a).to eql([jane_with_task, joe_with_task])
  end

  it 'loads a combined relation with one child restricted by given criteria' do
    jane_id = conn[:users].insert name: 'Jane'
    joe_id = conn[:users].insert name: 'Joe'

    conn[:tasks].insert user_id: joe_id, title: 'Joe Task'
    conn[:tasks].insert user_id: jane_id, title: 'Jane Task'

    expect(repo.users_with_task_by_title('Joe Task').to_a).to eql([jane_without_task, joe_with_task])
  end

  describe '#each' do
    before do
      conn[:users].insert name: 'Jane'
      conn[:users].insert name: 'Joe'
    end

    it 'yields loaded structs' do
      result = []

      repo.all_users.each { |user| result << user }

      expect(result).to eql([jane, joe])
    end

    it 'returns an enumerator when block is not given' do
      expect(repo.all_users.each.to_a).to eql([jane, joe])
    end
  end
end
