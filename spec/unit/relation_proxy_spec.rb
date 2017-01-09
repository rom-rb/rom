require 'dry-struct'

RSpec.describe 'loading proxy' do
  include_context 'database'
  include_context 'relations'
  include_context 'repo'
  include_context 'structs'
  include_context 'seeds'

  let(:users) do
    ROM::Repository::RelationProxy.new(rom.relation(:users), name: :users)
  end

  let(:tasks) do
    ROM::Repository::RelationProxy.new(rom.relation(:tasks), name: :tasks)
  end

  let(:tags) do
    ROM::Repository::RelationProxy.new(rom.relation(:tags), name: :tags)
  end

  describe '#inspect' do
    specify do
      expect(users.inspect).
        to eql("#<ROM::Relation[Users] name=users dataset=#{users.dataset.inspect}>")
    end
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
    end

    context 'setting custom model type' do
      let(:user_type) do
        Class.new(Dry::Struct) do
          attribute :id, Dry::Types['strict.int']
          attribute :name, Dry::Types['strict.string']
        end
      end

      let(:custom_users) { users.as(user_type) }

      it 'instantiates custom model' do
        expect(custom_users.where(name: 'Jane').one).to be_instance_of(user_type)
      end
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
        [:relation, [
          :users,
          { dataset: :users },
          [:header, [[:attribute, users.schema[:id]], [:attribute, users.schema[:name]]]]]
        ]
      )
    end

    it 'returns valid ast for a combined relation' do
      relation = users.combine(many: { user_tasks: [tasks, id: :user_id] })

      expect(relation.to_ast).to eql(
        [:relation, [
          :users,
          { dataset: :users },
          [:header, [
            [:attribute, users.schema[:id]],
            [:attribute, users.schema[:name]],
            [:relation, [
              :tasks,
              { dataset: :tasks, keys: { id: :user_id }, combine_type: :many, combine_name: :user_tasks },
              [:header, [
                 [:attribute, tasks.schema[:id]],
                 [:attribute, tasks.schema[:user_id]],
                 [:attribute, tasks.schema[:title]]]]
            ]]
          ]
        ]]]
      )
    end

    it 'returns valid ast for a wrapped relation' do
      relation = tags.wrap_parent(task: tasks)

      tags_schema = tags.schema.qualified
      tasks_schema = tasks.schema.wrap.qualified

      expect(relation.to_ast).to eql(
        [:relation, [
          :tags,
          { dataset: :tags },
          [:header, [
            [:attribute, tags_schema[:id]],
            [:attribute, tags_schema[:task_id]],
            [:attribute, tags_schema[:name]],
            [:relation, [
              :tasks,
              { dataset: :tasks, keys: { id: :task_id }, wrap: true, combine_name: :task },
              [:header, [
                 [:attribute, tasks_schema[:id]],
                 [:attribute, tasks_schema[:user_id]],
                 [:attribute, tasks_schema[:title]]]]
            ]]
          ]]
        ]]
      )
    end
  end

  describe '#method_missing' do
    it 'proxies to the underlying relation' do
      expect(users.gateway).to be(:default)
    end

    it 'returns proxy when response was not materialized' do
      expect(users.by_pk(1)).to be_instance_of(ROM::Repository::RelationProxy)
    end

    it 'returns curried proxy when response was curried' do
      expect(users.by_pk).to be_instance_of(ROM::Repository::RelationProxy)
    end

    it 'raises when method is missing' do
      expect { users.not_here }.to raise_error(NoMethodError, /not_here/)
    end
  end
end
