RSpec.describe 'loading proxy' do
  include_context 'database'
  include_context 'repo'
  include_context 'structs'
  include_context 'relations'
  include_context 'seeds'

  let(:users) do
    ROM::Repository::LoadingProxy.new(rom.relation(:users), name: :users)
  end

  let(:tasks) do
    ROM::Repository::LoadingProxy.new(rom.relation(:tasks), name: :tasks)
  end

  let(:tags) do
    ROM::Repository::LoadingProxy.new(rom.relation(:tags), name: :tags)
  end

  describe '#each' do
    it 'yields loaded structs' do
      result = []

      users.each { |user| result << user }

      expect(result).to eql([jane, joe])
    end

    it 'returns an enumerator when block is not given' do
      expect(users.each.to_a).to eql([jane, joe])
    end
  end

  describe 'retrieving a single struct' do
    describe '#first' do
      it 'returns exactly one struct' do
        expect(users.first).to eql(jane)
      end
    end

    describe '#one' do
      it 'returns exactly one struct' do
        expect(users.find(id: 1).one).to eql(jane)

        expect(users.find(id: 3).one).to be(nil)

        expect { users.find(id: [1,2]).one }.to raise_error(ROM::TupleCountMismatchError)
      end
    end

    describe '#one!' do
      it 'returns exactly one struct' do
        expect(users.find(id: 1).one!).to eql(jane)

        expect { users.find(id: [1, 2]).one! }.to raise_error(ROM::TupleCountMismatchError)
        expect { users.find(id: [3]).one! }.to raise_error(ROM::TupleCountMismatchError)
      end
    end
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

    it 'returns valid ast for a wrapped relation' do
      relation = tags.wrap_parent(task: tasks)

      expect(relation.to_ast).to eql(
        [
          :relation, :tags, [
            :header, [
              [:attribute, :id],
              [:attribute, :task_id],
              [:attribute, :name],
              [
                :relation, :task, [
                  :header, [
                    [:attribute, :id],
                    [:attribute, :user_id],
                    [:attribute, :title]
                  ]
                ],
                { base_name: :tasks, keys: { id: :task_id }, wrap: true }
              ]
            ]
          ],
          base_name: :tags
        ]
      )
    end
  end
end
