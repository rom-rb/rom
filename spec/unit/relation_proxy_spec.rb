require 'dry-struct'

RSpec.describe 'loading proxy' do
  include_context 'database'
  include_context 'relations'
  include_context 'repo'
  include_context 'structs'
  include_context 'seeds'

  let(:users_proxy) do
    ROM::Repository::RelationProxy.new(users, name: :users)
  end

  let(:tasks_proxy) do
    ROM::Repository::RelationProxy.new(tasks, name: :tasks)
  end

  let(:tags_proxy) do
    ROM::Repository::RelationProxy.new(tags, name: :tags)
  end

  describe '#inspect' do
    specify do
      expect(users_proxy.inspect).
        to eql("#<ROM::Relation[Users] name=users dataset=#{users.dataset.inspect}>")
    end
  end

  describe '#each' do
    it 'yields loaded structs' do
      result = []

      users_proxy.each { |user| result << user }

      expect(result).to eql([jane, joe])
    end

    it 'returns an enumerator when block is not given' do
      expect(users_proxy.each.to_a).to eql([jane, joe])
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
        expect(users_proxy.map_with(:name_list, :upcase_names).to_a).to match_array(%w(JANE JOE))
      end

      it 'does not use the default(ROM::Struct) mapper' do
        expect(users_proxy.map_with(:identity).to_a).to match_array(
          [{ id: 1, name: 'Jane' }, {id: 2, name: 'Joe' }]
        )
      end

      it 'raises error when custom mapper is used with a model class' do
        expect { users_proxy.map_with(:name_list, Class.new) }.
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

      let(:custom_users) { users_proxy.as(user_type) }

      it 'instantiates custom model' do
        expect(custom_users.where(name: 'Jane').one).to be_instance_of(user_type)
      end
    end
  end

  describe 'retrieving a single struct' do
    describe '#first' do
      it 'returns exactly one struct' do
        expect(users_proxy.first).to eql(jane)
      end
    end

    describe '#one' do
      it 'returns exactly one struct' do
        expect(users_proxy.find(id: 1).one).to eql(jane)

        expect(users_proxy.find(id: 3).one).to be(nil)

        expect { users_proxy.find(id: [1,2]).one }.to raise_error(ROM::TupleCountMismatchError)
      end
    end

    describe '#one!' do
      it 'returns exactly one struct' do
        expect(users_proxy.find(id: 1).one!).to eql(jane)

        expect { users_proxy.find(id: [1, 2]).one! }.to raise_error(ROM::TupleCountMismatchError)
        expect { users_proxy.find(id: [3]).one! }.to raise_error(ROM::TupleCountMismatchError)
      end
    end
  end

  describe '#to_ast' do
    it 'returns valid ast for a single relation' do
      expect(users_proxy.to_ast).to eql(
        [:relation, [
          :users,
          { dataset: :users },
          [:header, [[:attribute, users_proxy.schema[:id]], [:attribute, users_proxy.schema[:name]]]]]
        ]
      )
    end

    it 'returns valid ast for a combined relation' do
      relation = users_proxy.combine(many: { user_tasks: [tasks_proxy, id: :user_id] })

      expect(relation.to_ast).to eql(
        [:relation, [
          :users,
          { dataset: :users },
          [:header, [
            [:attribute, users_proxy.schema[:id]],
            [:attribute, users_proxy.schema[:name]],
            [:relation, [
              :tasks,
              { dataset: :tasks, keys: { id: :user_id },
                combine_type: :many, combine_name: :user_tasks },
              [:header, [
                 [:attribute, tasks_proxy.schema[:id]],
                 [:attribute, tasks_proxy.schema[:user_id]],
                 [:attribute, tasks_proxy.schema[:title]]]]
            ]]
          ]
        ]]]
      )
    end

    it 'returns valid ast for a wrapped relation' do
      relation = tags_proxy.wrap_parent(task: tasks_proxy)

      tags_schema = tags_proxy.schema.qualified
      tasks_schema = tasks_proxy.schema.wrap

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
              { dataset: :tasks, keys: { id: :task_id },
                wrap_from_assoc: false, wrap: true, combine_name: :task },
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
      expect(users_proxy.gateway).to be(:default)
    end

    it 'returns proxy when response was not materialized' do
      expect(users_proxy.by_pk(1)).to be_instance_of(ROM::Repository::RelationProxy)
    end

    it 'returns curried proxy when response was curried' do
      expect(users_proxy.by_pk).to be_instance_of(ROM::Repository::RelationProxy)
    end

    it 'raises when method is missing' do
      expect { users_proxy.not_here }.to raise_error(NoMethodError, "undefined method `not_here' for ROM::Relation[Users]")
    end
  end
end
