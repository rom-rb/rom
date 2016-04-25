require 'spec_helper'
require 'rom/memory'

describe ROM::Relation, '.schema' do
  it 'defines a canonical schema for a relation' do
    class Test::Users < ROM::Relation[:memory]
      schema do
        attribute :id, Types::Int.meta(primary_key: true)
        attribute :name, Types::String
        attribute :admin, Types::Bool
      end
    end

    schema = ROM::Schema.new(
      :test_users,
      id: ROM::Memory::Types::Int.meta(primary_key: true, name: :id),
      name: ROM::Memory::Types::String.meta(name: :name),
      admin: ROM::Memory::Types::Bool.meta(name: :admin)
    )

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

    schema = Test::Users.schema

    expect(schema.primary_key).to eql([schema[:name], schema[:email]])
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
end
