require 'dry-struct'

RSpec.describe 'loading proxy' do
  include_context 'database'
  include_context 'relations'
  include_context 'repo'
  include_context 'structs'
  include_context 'seeds'

  let(:users_relation) do
    repo.users.with(auto_map: true, auto_struct: true)
  end

  let(:tasks_relation) do
    repo.tasks.with(auto_map: true, auto_struct: true)
  end

  let(:tags_relation) do
    repo.tags.with(auto_map: true, auto_struct: true)
  end

  describe '#inspect' do
    specify do
      expect(users_relation.inspect).
        to eql("#<ROM::Relation[Users] name=ROM::Relation::Name(users) dataset=#{users.dataset.inspect}>")
    end
  end

  describe '#each' do
    it 'yields loaded structs' do
      result = []

      users_relation.each { |user| result << user }

      expect(result).to eql([jane, joe])
    end

    it 'returns an enumerator when block is not given' do
      expect(users_relation.each.to_a).to eql([jane, joe])
    end
  end

  describe '#map_with/#as' do
    context 'with custom mappers' do
      before do
        configuration.mappers do
          register :users, {
            name_list: -> users { users.map { |u| u[:name] } },
            upcase_names: -> names { names.map(&:upcase) },
            identity: -> users { users }
          }
        end
      end

      it 'sends the relation through custom mappers' do
        expect(users.map_with(:name_list, :upcase_names).to_a).to match_array(%w(JANE JOE))
      end

      it 'does not use the default(ROM::Struct) mapper' do
        expect(users.map_with(:identity).to_a).to match_array(
          [{ id: 1, name: 'Jane' }, {id: 2, name: 'Joe' }]
        )
      end

      it 'raises error when custom mapper is used with a model class' do
        expect { users.map_with(:name_list, Class.new) }.
          to raise_error(ArgumentError, 'using custom mappers and a model is not supported')
      end
    end

    context 'setting custom model type' do
      let(:user_type) do
        Class.new(Dry::Struct) do
          attribute :id, Dry::Types['strict.int']
          attribute :name, Dry::Types['strict.string']
        end
      end

      let(:custom_users) { users_relation.as(user_type) }

      it 'instantiates custom model' do
        expect(custom_users.where(name: 'Jane').one).to be_instance_of(user_type)
      end
    end
  end

  describe 'retrieving a single struct' do
    describe '#first' do
      it 'returns exactly one struct' do
        expect(users_relation.first).to eql(jane)
      end
    end

    describe '#one' do
      it 'returns exactly one struct' do
        expect(users_relation.find(id: 1).one).to eql(jane)

        expect(users_relation.find(id: 3).one).to be(nil)

        expect { users_relation.find(id: [1,2]).one }.to raise_error(ROM::TupleCountMismatchError)
      end
    end

    describe '#one!' do
      it 'returns exactly one struct' do
        expect(users_relation.find(id: 1).one!).to eql(jane)

        expect { users_relation.find(id: [1, 2]).one! }.to raise_error(ROM::TupleCountMismatchError)
        expect { users_relation.find(id: [3]).one! }.to raise_error(ROM::TupleCountMismatchError)
      end
    end
  end

  describe '#to_ast' do
    it 'returns valid ast for a single relation' do
      expect(users_relation.to_ast).to eql(
        [:relation, [
          :users,
          [
            [:attribute, users_relation.schema[:id]],
            [:attribute, users_relation.schema[:name]]
          ],
          { dataset: :users }
        ]]
      )
    end

    it 'returns valid ast for a combined relation' do
      relation = users_relation.combine(many: { user_tasks: [tasks_relation, id: :user_id] })

      expect(relation.to_ast).to eql(
        [:relation, [
          :users,
          [
            [:attribute, users_relation.schema[:id]],
            [:attribute, users_relation.schema[:name]],
            [:relation, [
              :tasks,
              [
                 [:attribute, tasks_relation.schema[:id]],
                 [:attribute, tasks_relation.schema[:user_id]],
                 [:attribute, tasks_relation.schema[:title]]
              ],
              { dataset: :tasks, model: false, keys: { id: :user_id },
                combine_type: :many, combine_name: :user_tasks }
            ]]
          ],
          { dataset: :users }
        ]]
      )
    end

    it 'returns valid ast for a wrapped relation' do
      relation = tags_relation.wrap_parent(task: tasks_relation)

      tags_schema = tags_relation.schema.qualified
      tasks_schema = tasks_relation.schema.wrap

      expect(relation.to_ast).to eql(
        [:relation, [
          :tags,
          [
            [:attribute, tags_schema[:id]],
            [:attribute, tags_schema[:task_id]],
            [:attribute, tags_schema[:name]],
            [:relation, [
              :tasks,
              [
                 [:attribute, tasks_schema[:id]],
                 [:attribute, tasks_schema[:user_id]],
                 [:attribute, tasks_schema[:title]]
              ],
              { dataset: :tasks, keys: { id: :task_id },
                wrap_from_assoc: false, wrap: true, combine_name: :task }
            ]]
          ],
          { dataset: :tags }
        ]]
      )
    end
  end
end
