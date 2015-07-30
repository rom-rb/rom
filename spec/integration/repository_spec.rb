RSpec.describe 'ROM repository' do
  include_context 'database'

  subject(:repo) { repo_class.new(rom) }

  let(:repo_class) do
    Class.new(ROM::Repository::Base) do
      relations :users, :tasks, :tags

      def find_users(criteria)
        users.find(criteria)
      end

      def all_users
        users.all
      end

      def task_with_user
        combine_parents(tasks.find(id: 2), one: { owner: users })
      end

      def users_with_tasks
        combine_children(users, many: { all_tasks: tasks.for_users })
      end

      def users_with_tasks_and_tags
        combine_children(
          users,
          many: { all_tasks: tasks_with_tags(tasks.for_users) }
        )
      end

      def tasks_with_tags(tasks = self.tasks)
        combine_children(tasks, many: { tags: tags })
      end

      def users_with_task
        combine_children(users, one: { task: tasks })
      end

      def users_with_task_by_title(title)
        combine_children(users, one: { task: tasks.find(title: title) })
      end
    end
  end

  before do
    setup.relation(:users) do
      def all
        select(:id, :name).order(:name, :id)
      end

      def find(criteria)
        where(criteria)
      end
    end

    setup.relation(:tasks) do
      def find(criteria)
        where(criteria)
      end

      def for_users(users)
        where(user_id: users.map { |u| u[:id] })
      end
    end
  end

  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }
  let(:tags) { rom.relation(:tags) }

  let(:user_struct) { repo.users.mapper.model }
  let(:task_struct) { repo.tasks.mapper.model }
  let(:tag_struct) { repo.tags.mapper.model }

  let(:user_with_tasks_struct) { mapper_for(repo.users_with_tasks).model }
  let(:user_with_task_struct) { mapper_for(repo.users_with_task).model }
  let(:task_with_tags_struct) { mapper_for(repo.tasks_with_tags).model }

  let(:jane) { user_struct.new(id: 1, name: 'Jane') }
  let(:jane_with_tasks) { user_with_tasks_struct.new(id: 1, name: 'Jane', all_tasks: [jane_task]) }
  let(:jane_with_task) { user_with_task_struct.new(id: 1, name: 'Jane', task: jane_task) }
  let(:jane_without_task) { user_with_task_struct.new(id: 1, name: 'Jane', task: nil) }
  let(:jane_task) { task_struct.new(id: 2, user_id: 1, title: 'Jane Task') }
  let(:task_with_user) { task_with_user_struct.new(id: 2, user_id: 1, title: 'Jane Task', owner: jane) }
  let(:tag) { tag_struct.new(id: 1, task_id: 2, name: 'red') }
  let(:task_with_tag) { task_with_tags_struct.new(id: 2, user_id: 1, title: 'Jane Task', tags: [tag]) }
  let(:user_with_task_and_tags) { user_with_tasks_struct.new(id: 1, name: 'Jane', all_tasks: [task_with_tag]) }

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

  it 'loads a combined relation with one parent' do
    jane_id = conn[:users].insert name: 'Jane'
    joe_id = conn[:users].insert name: 'Joe'

    conn[:tasks].insert user_id: joe_id, title: 'Joe Task'
    conn[:tasks].insert user_id: jane_id, title: 'Jane Task'

    expect(repo.users_with_task.first).to eql(jane_with_task)
  end

  it 'loads nested combined relations' do
    jane_id = conn[:users].insert name: 'Jane'
    joe_id = conn[:users].insert name: 'Joe'

    conn[:tasks].insert user_id: joe_id, title: 'Joe Task'
    task_id = conn[:tasks].insert user_id: jane_id, title: 'Jane Task'

    conn[:tags].insert task_id: task_id, name: 'red'

    expect(repo.users_with_tasks_and_tags.first).to eql(user_with_task_and_tags)
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

  describe 'retrieving a single struct' do
    before do
      conn[:users].insert name: 'Jane'
      conn[:users].insert name: 'Joe'
    end

    describe '#first' do
      it 'returns exactly one struct' do
        expect(repo.all_users.first).to eql(jane)
      end
    end

    describe '#one' do
      it 'returns exactly one struct' do
        expect(repo.find_users(id: 1).one).to eql(jane)

        expect(repo.find_users(id: 3).one).to be(nil)

        expect { repo.find_users(id: [1,2]).one }.to raise_error(ROM::TupleCountMismatchError)
      end
    end

    describe '#one!' do
      it 'returns exactly one struct' do
        expect(repo.find_users(id: 1).one!).to eql(jane)

        expect { repo.find_users(id: [1, 2]).one! }.to raise_error(ROM::TupleCountMismatchError)
        expect { repo.find_users(id: [3]).one! }.to raise_error(ROM::TupleCountMismatchError)
      end
    end
  end
end
