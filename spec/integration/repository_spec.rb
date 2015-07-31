RSpec.describe 'ROM repository' do
  include_context 'database'
  include_context 'relations'
  include_context 'structs'

  before do
    jane_id = conn[:users].insert name: 'Jane'
    joe_id = conn[:users].insert name: 'Joe'

    conn[:tasks].insert user_id: joe_id, title: 'Joe Task'
    task_id = conn[:tasks].insert user_id: jane_id, title: 'Jane Task'

    conn[:tags].insert task_id: task_id, name: 'red'
  end

  it 'loads a single relation' do
    expect(repo.all_users.to_a).to eql([jane, joe])
  end

  it 'loads a combined relation with many children' do
    expect(repo.users_with_tasks.to_a).to eql([jane_with_tasks, joe_with_tasks])
  end

  it 'loads a combined relation with one child' do
    expect(repo.users_with_task.to_a).to eql([jane_with_task, joe_with_task])
  end

  it 'loads a combined relation with one child restricted by given criteria' do
    expect(repo.users_with_task_by_title('Joe Task').to_a).to eql([jane_without_task, joe_with_task])
  end

  it 'loads a combined relation with one parent' do
    expect(repo.users_with_task.first).to eql(jane_with_task)
  end

  it 'loads nested combined relations' do
    expect(repo.users_with_tasks_and_tags.first).to eql(user_with_task_and_tags)
  end

  describe '#each' do
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
