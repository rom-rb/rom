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

    relation_name = ROM::Relation::Name[:test_users]

    schema = ROM::Memory::Schema.define(
      ROM::Relation::Name.new(:test_users),
      attributes: [
        ROM::Memory::Types::Int.meta(primary_key: true, name: :id, source: relation_name),
        ROM::Memory::Types::String.meta(name: :name, source: relation_name),
        ROM::Memory::Types::Bool.meta(name: :admin, source: relation_name)
      ]
    ).finalize!

    expect(Test::Users.schema.primary_key).to eql([Test::Users.schema[:id]])

    expect(Test::Users.schema).to eql(schema)

    expect(Test::Users.schema.relations).to be_empty
  end

  it 'allows defining types for reading tuples' do
    module Test
      module Types
        CoercibleDate = ROM::Types::Date.constructor(Date.method(:parse))
      end
    end

    class Test::Users < ROM::Relation[:memory]
      schema do
        attribute :id, Types::Int
        attribute :date, Types::Coercible::String, read: Test::Types::CoercibleDate
      end
    end

    schema = Test::Users.schema

    expect(schema.to_output_hash).
      to eql(ROM::Types::Coercible::Hash.schema(id: schema[:id].type, date: schema[:date].meta[:read]))
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

  it 'allows JSON read/write coersion', aggregate_failures: true do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::JSON
      end
    end

    schema = Test::Posts.schema
    json_payload = '{"foo":"bar"}'
    hash_payload = { "foo" => "bar" }

    expect(schema[:payload][hash_payload]).to eq(json_payload)
    expect(schema[:payload].meta[:read][json_payload]).to eq(hash_payload)
  end

  it 'allows JSON/Hash read/write coersion using symbols as keys', aggregate_failures: true do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::JSON(symbol_keys: true)
      end
    end

    schema = Test::Posts.schema
    json_payload = '{"foo":"bar"}'
    hash_payload = { foo: "bar" }

    expect(schema[:payload][hash_payload]).to eq(json_payload)
    expect(schema[:payload].meta[:read][json_payload]).to eq(hash_payload)
  end

  it 'allows JSON to Hash coersion only' do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::JSONHash
      end
    end

    schema = Test::Posts.schema
    json_payload = '{"foo":"bar"}'
    hash_payload = { "foo" => "bar" }

    expect(schema[:payload][json_payload]).to eq(hash_payload)
  end

  it 'returns original payload in JSON to Hash coersion when json is invalid' do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::JSONHash
      end
    end

    schema = Test::Posts.schema
    json_payload = 'invalid: json'

    expect(schema[:payload][json_payload]).to eq(json_payload)
  end

  it 'allows JSON to Hash coersion only using symbols as keys' do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::JSONHash(symbol_keys: true)
      end
    end

    schema = Test::Posts.schema
    json_payload = '{"foo":"bar"}'
    hash_payload = { foo: "bar" }

    expect(schema[:payload][json_payload]).to eq(hash_payload)
  end

  it 'allows Hash to JSON coersion only' do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::HashJSON
      end
    end

    schema = Test::Posts.schema
    json_payload = '{"foo":"bar"}'
    hash_payload = { "foo" => "bar" }

    expect(schema[:payload][hash_payload]).to eq(json_payload)
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

  it 'allows setting both dataset and relation alias' do
    class Test::Users < ROM::Relation[:memory]
      schema(:test_users, as: :users) { }
    end

    expect(Test::Users.register_as).to be(:users)
    expect(Test::Users.dataset).to be(:test_users)
  end

  it 'raises error when schema_class is missing' do
    class Test::Users < ROM::Relation[:memory]
      schema_class nil
    end

    expect { Test::Users.schema(:test) { } }.
      to raise_error(ROM::MissingSchemaClassError, "Test::Users relation is missing schema_class")
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

      expect(Test::Users.schema[:admin]).to eql(ROM::Types::Bool.meta(name: :admin, source: ROM::Relation::Name[:test_users]))
    end

    it 'raises an error on double definition' do
      expect {
        class Test::Users < ROM::Relation[:memory]
          schema do
            attribute :id, Types::Int.meta(primary_key: true)
            attribute :name, Types::String
            attribute :id, Types::Int
          end
        end
      }.to raise_error(ROM::Schema::AttributeAlreadyDefinedError,
                       /:id already defined/)
    end
  end
end
