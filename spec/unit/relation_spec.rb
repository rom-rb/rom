RSpec.describe 'relation ext' do
  include_context 'database'

  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }

  before do
    setup.relation(:users)
    setup.relation(:tasks)
  end

  describe '#to_ast' do
    it 'returns valid ast for a single relation' do
      expect(users.to_ast).to eql([:relation, :users, [:id, :name]])
    end

    it 'returns valid ast for a combined relation' do
      expect(users.combine(tasks).to_ast).to eql(
        [
          :graph,
          [:relation, :users, [:id, :name]], [
            [:relation, :tasks, [:id, :user_id, :title]]
          ]
        ]
      )
    end
  end
end
