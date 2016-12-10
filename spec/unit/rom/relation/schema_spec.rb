require 'spec_helper'
require 'rom/memory'

RSpec.describe ROM::Relation, '.schema' do
  it 'defines a canonical schema for a relation' do
    class Test::Users < ROM::Relation[:memory]
      schema do
        attribute :id, Types::Int.meta(primary_key: true)
        attribute :name, Types::String
        attribute :admin, Types::Bool
      end
    end

    Test::Users.schema.finalize!

    schema = ROM::Schema.define(
      ROM::Relation::Name.new(:test_users),
      attributes: {
        id: ROM::Memory::Types::Int.meta(primary_key: true, name: :id),
        name: ROM::Memory::Types::String.meta(name: :name),
        admin: ROM::Memory::Types::Bool.meta(name: :admin)
      }
    ).finalize!

    expect(Test::Users.schema.primary_key).to eql([Test::Users.schema[:id]])

    expect(Test::Users.schema).to eql(schema)
  end

  it 'allows setting composite primary key' do
    class Test::Users < ROM::Relation[:memory]
      schema do
        attribute :name, Types::String
        attribute :email, Types::String

        primary_key :name, :email
      end
    end

    schema = Test::Users.schema.finalize!

    expect(schema.primary_key).to eql([schema[:name], schema[:email]])
  end

  it 'allows setting foreign keys' do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :author_id, Types::ForeignKey(:users)
        attribute :title, Types::String
      end
    end

    schema = Test::Posts.schema

    expect(schema[:author_id].primitive).to be(Integer)

    expect(schema.foreign_key(:users)).to be(schema[:author_id])
  end

  it 'sets register_as and dataset' do
    class Test::Users < ROM::Relation[:memory]
      schema(:users) do
        attribute :id, Types::Int
        attribute :name, Types::String
      end
    end

    expect(Test::Users.dataset).to be(:users)
    expect(Test::Users.register_as).to be(:users)
  end

  it 'sets dataset and respects custom register_as' do
    class Test::Users < ROM::Relation[:memory]
      register_as :test_users

      schema(:users) do
        attribute :id, Types::Int
        attribute :name, Types::String
      end
    end

    expect(Test::Users.dataset).to be(:users)
    expect(Test::Users.register_as).to be(:test_users)
  end

  describe '#schema' do
    it 'returns defined schema' do
      class Test::Users < ROM::Relation[:memory]
        schema do
          attribute :id, Types::Int.meta(primary_key: true)
          attribute :name, Types::String
          attribute :admin, Types::Bool
        end
      end

      users = Test::Users.new([])

      expect(users.schema).to be(Test::Users.schema)
    end

    it 'uses custom schema dsl' do
      class Test::SchemaDSL < ROM::Schema::DSL
        def bool(name)
          attribute(name, ::ROM::Types::Bool)
        end
      end

      class Test::Users < ROM::Relation[:memory]
        schema_dsl Test::SchemaDSL

        schema do
          bool :admin
        end
      end

      expect(Test::Users.schema[:admin]).to eql(ROM::Types::Bool.meta(name: :admin))
    end
  end
end
