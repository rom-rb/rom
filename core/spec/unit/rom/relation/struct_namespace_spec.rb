require 'rom/relation'

RSpec.describe ROM::Relation, '#struct_namespace' do
  let(:dataset) do
    [{ id: 1, name: 'Jane', age: 30 }]
  end

  before do
    module Test::BaseEntities
      class User < ROM::Struct
        def name
          "Not Jane"
        end

        def age
          "#{super} years old"
        end

        def shared_user?
          true
        end
      end
    end

    module Test::Entities
      class User < Test::BaseEntities::User
        def my_user?
          true
        end
      end

      class Admin < User
        def admin?
          true
        end
      end
    end

    module Test::Models
      class User < ROM::Struct
        def super_user?
          true
        end
      end
    end
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

    it 'returns a new relation configured for the provided struct namespace' do
      users = relation.struct_namespace(Test::Entities)

      expect(users.first).to be_my_user
    end

    it 'returns a new relation configured for the provided struct namespace and aliased relation' do
      users = relation.as(:admins).struct_namespace(Test::Entities)

      expect(users.first).to be_admin
    end

    it 'allows switching namespaces at runtime' do
      entities = relation.struct_namespace(Test::Entities)
      models = relation.struct_namespace(Test::Models)

      expect(entities.first).to be_my_user
      expect(models.first).to be_super_user
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

    it 'returns a new relation configured for the provided struct namespace' do
      expect(relation.first).to be_my_user
    end
  end

  describe 'struct behavior' do
    let(:users) do
      Class.new(ROM::Relation) do
        struct_namespace Test::BaseEntities

        schema(:users) do
          attribute :id, ROM::Types::Int
          attribute :name, ROM::Types::String
          attribute :age, ROM::Types::Int
        end
      end.new(dataset, auto_struct: true)
    end

    it 'gives access to the attributes' do
      expect(users.first.id).to eq 1
    end

    it 'allows overriding attribute methods and referring to the original value' do
      expect(users.first.age).to eq "30 years old"
    end

    it 'allows overriding attribute methods without referring to the original value' do
      expect(users.first.name).to eq "Not Jane"
    end

    context 'using inheritance' do
      let(:admins) do
        Class.new(ROM::Relation) do
          struct_namespace Test::Entities

          schema(:users, as: :admins) do
            attribute :id, ROM::Types::Int
            attribute :name, ROM::Types::String
            attribute :age, ROM::Types::Int
          end
        end.new(dataset, auto_struct: true)
      end

      it 'inherits struct namespace and uses custom alias' do
        expect(admins.first).to be_admin
      end

      it 'gives access to non-attribute methods defined in the struct superclass' do
        expect(admins.first).to be_shared_user
      end

      it 'gives access to overridden attribute methods idefined n the struct superclass' do
        expect(admins.first.age).to eq "30 years old"
        expect(admins.first.name).to eq "Not Jane"
      end
    end
  end
end
