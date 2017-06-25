require 'rom/relation'

RSpec.describe ROM::Relation, '#struct_namespace' do
  let(:dataset) do
    [{ id: 1, name: 'Jane' }]
  end

  context 'setting at runtime' do
    subject(:relation) do
      Class.new(ROM::Relation) do
        schema(:users) do
          attribute :id, ROM::Types::Int
          attribute :name, ROM::Types::String
        end
      end.new(dataset, auto_struct: true)
    end

    before do
      module Test::Entities
        class User < ROM::Struct
          def my_user?
            true
          end
        end
      end
    end

    it 'returns a new relation configured for the provided struct namespace' do
      users = relation.struct_namespace(Test::Entities)

      expect(users.first).to be_my_user
    end
  end

  context 'using default setting' do
    subject(:relation) do
      Class.new(ROM::Relation) do
        struct_namespace Test::Entities

        schema(:users) do
          attribute :id, ROM::Types::Int
          attribute :name, ROM::Types::String
        end
      end.new(dataset, auto_struct: true)
    end

    before do
      module Test::Entities
        class User < ROM::Struct
          def my_user?
            true
          end
        end
      end
    end

    it 'returns a new relation configured for the provided struct namespace' do
      expect(relation.first).to be_my_user
    end
  end
end
