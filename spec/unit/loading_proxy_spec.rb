RSpec.describe 'loading proxy' do
  include_context 'database'

  let(:users) { ROM::Repository::LoadingProxy.new(rom.relation(:users), name: :users) }
  let(:tasks) { ROM::Repository::LoadingProxy.new(rom.relation(:tasks), name: :tasks) }

  before do
    setup.relation(:users)
    setup.relation(:tasks)
  end

  describe '#to_ast' do
    it 'returns valid ast for a single relation' do
      expect(users.to_ast).to eql(
        [
          :relation, :users, [
            :header, [[:attribute, :id], [:attribute, :name]]
          ],
          base_name: :users
        ]
      )
    end

    it 'returns valid ast for a combined relation' do
      relation = users.combine(many: { user_tasks: [tasks, id: :user_id] })

      expect(relation.to_ast).to eql(
        [
          :relation, :users, [
            :header, [
              [:attribute, :id],
              [:attribute, :name],
              [
                :relation, :user_tasks, [
                  :header, [
                    [:attribute, :id],
                    [:attribute, :user_id],
                    [:attribute, :title]
                  ]
                ],
                { base_name: :tasks, keys: { id: :user_id }, combine_type: :many }
              ]
            ]
          ],
          base_name: :users
        ]
      )
    end
  end
end
