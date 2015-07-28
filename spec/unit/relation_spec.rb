RSpec.describe 'relation ext' do
  include_context 'database'

  let(:users) { ROM::Repository::LoadingProxy.new(:users, rom.relation(:users)) }
  let(:tasks) { ROM::Repository::LoadingProxy.new(:users, rom.relation(:tasks)) }

  before do
    setup.relation(:users)
    setup.relation(:tasks)
  end

  describe '#to_ast' do
    it 'returns valid ast for a single relation' do
      expect(users.to_ast).to eql([:relation, :users, [:id, :name]])
    end

    it 'returns valid ast for a combined relation' do
      relation = users.combine(user_tasks: tasks)

      expect(relation.to_ast).to eql(
        [
          :graph,
          [:relation, :users, [:id, :name]], [
            [:relation, :user_tasks, [:id, :user_id, :title]]
          ]
        ]
      )
    end
  end
end
