# frozen_string_literal: true

require 'spec_helper'
require 'rom/memory'

RSpec.describe ROM::Relation, '.schema' do
  it 'defines a canonical schema for a relation' do
    class Test::Users < ROM::Relation[:memory]
      schema do
        attribute :id, Types::Integer.meta(primary_key: true)
        attribute :name, Types::String
        attribute :admin, Types::Bool
      end
    end

    Test::Users.schema_proc.call.finalize_attributes!

    relation_name = ROM::Relation::Name[:test_users]

    schema = ROM::Memory::Schema.define(
      ROM::Relation::Name.new(:test_users),
      attributes: [
        { type: ROM::Memory::Types::Integer.meta(primary_key: true, source: relation_name),
          options: { name: :id } },
        { type: ROM::Memory::Types::String.meta(source: relation_name),
          options: { name: :name } },
        { type: ROM::Memory::Types::Bool.meta(source: relation_name),
          options: { name: :admin } }
      ]
    ).finalize_attributes!

    expect(schema.primary_key).to eql([schema[:id]])
    expect(schema.primary_key_name).to be(:id)
    expect(schema.primary_key_names).to eql([:id])

    expect(schema).to eql(schema)

    expect(schema.relations).to be_empty
  end

  it 'allows defining types for reading tuples' do
    module Test
      module Types
        CoercibleDate = ROM::Types::Date.constructor(Date.method(:parse))
      end
    end

    class Test::Users < ROM::Relation[:memory]
      schema do
        attribute :id, Types::Integer
        attribute :date, Types::Coercible::String, read: Test::Types::CoercibleDate
      end
    end

    schema = Test::Users.schema_proc.call

    expect(schema.to_output_hash)
      .to eql(ROM::Schema::HASH_SCHEMA.schema(id: schema[:id].type, date: schema[:date].meta[:read]))
  end

  it 'allows setting composite primary key using `primary_key` macro' do
    class Test::Users < ROM::Relation[:memory]
      schema do
        attribute :name, Types::String
        attribute :email, Types::String

        primary_key :name, :email
      end
    end

    schema = Test::Users.schema_proc.call.finalize_attributes!

    expect(schema.primary_key).to eql([schema[:name], schema[:email]])
  end

  it 'allows setting composite primary key using attribute options' do
    class Test::Users < ROM::Relation[:memory]
      schema do
        attribute :name, Types::String, primary_key: true
        attribute :email, Types::String
      end
    end

    schema = Test::Users.schema_proc.call.finalize_attributes!

    expect(schema.primary_key).to eql([schema[:name]])
  end

  it 'allows setting foreign keys using Types::ForeignKey' do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :author_id, Types::ForeignKey(:users)
        attribute :title, Types::String
      end
    end

    schema = Test::Posts.schema_proc.call

    expect(schema[:author_id].primitive).to be(Integer)

    expect(schema.foreign_key(:users)).to be(schema[:author_id])
  end

  it 'allows setting foreign keys using attribute options' do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :author_id, Types::Integer, foreign_key: true, target: :users
        attribute :title, Types::String
      end
    end

    schema = Test::Posts.schema_proc.call

    expect(schema[:author_id].primitive).to be(Integer)

    expect(schema.foreign_key(:users)).to be(schema[:author_id])
  end

  it 'allows setting attribute options' do
    class Test::Users < ROM::Relation[:memory]
      schema do
        attribute :name, Types::String, alias: :username
      end
    end

    schema = Test::Users.schema_proc.call

    expect(schema[:name].alias).to be(:username)
  end

  it 'allows setting attribute options while still leaving type undefined' do
    class Test::Users < ROM::Relation[:memory]
      schema do
        attribute :name, alias: :username
      end
    end

    schema = Test::Users.schema_proc.call

    expect(schema[:name].alias).to be(:username)
    expect(schema[:name].type).to be_nil
  end

  it 'allows JSON read/write coersion', aggregate_failures: true do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::JSON
      end
    end

    schema = Test::Posts.schema_proc.call
    json_payload = '{"foo":"bar"}'
    hash_payload = { 'foo' => 'bar' }

    expect(schema[:payload][hash_payload]).to eq(json_payload)
    expect(schema[:payload].meta[:read][json_payload]).to eq(hash_payload)
  end

  it 'allows JSON read/write coersion using symbols', aggregate_failures: true do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::JSON(symbol_keys: true)
      end
    end

    schema = Test::Posts.schema_proc.call
    json_payload = '{"foo":"bar"}'
    hash_payload = { foo: 'bar' }

    expect(schema[:payload][hash_payload]).to eq(json_payload)
    expect(schema[:payload].meta[:read][json_payload]).to eq(hash_payload)
  end

  it 'allows JSON read/write coersion', aggregate_failures: true do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::JSON
      end
    end

    schema = Test::Posts.schema_proc.call
    json_payload = '{"foo":"bar"}'
    hash_payload = { 'foo' => 'bar' }

    expect(schema[:payload][hash_payload]).to eq(json_payload)
    expect(schema[:payload].meta[:read][json_payload]).to eq(hash_payload)
  end

  it 'allows JSON to Hash coersion only' do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::JSONHash
      end
    end

    schema = Test::Posts.schema_proc.call
    json_payload = '{"foo":"bar"}'
    hash_payload = { 'foo' => 'bar' }

    expect(schema[:payload][json_payload]).to eq(hash_payload)
  end

  it 'returns original payload in JSON to Hash coersion when json is invalid' do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::JSONHash
      end
    end

    schema = Test::Posts.schema_proc.call
    json_payload = 'invalid: json'

    expect(schema[:payload][json_payload]).to eq(json_payload)
  end

  it 'allows JSON to Hash coersion only using symbols as keys' do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::JSONHash(symbol_keys: true)
      end
    end

    schema = Test::Posts.schema_proc.call
    json_payload = '{"foo":"bar"}'
    hash_payload = { foo: 'bar' }

    expect(schema[:payload][json_payload]).to eq(hash_payload)
  end

  it 'allows Hash to JSON coersion only' do
    class Test::Posts < ROM::Relation[:memory]
      schema do
        attribute :payload, Types::Coercible::HashJSON
      end
    end

    schema = Test::Posts.schema_proc.call
    json_payload = '{"foo":"bar"}'
    hash_payload = { 'foo' => 'bar' }

    expect(schema[:payload][hash_payload]).to eq(json_payload)
  end

  it 'sets register_as and dataset' do
    class Test::Users < ROM::Relation[:memory]
      schema(:users) do
        attribute :id, Types::Integer
        attribute :name, Types::String
      end
    end

    expect(Test::Users.relation_name.dataset).to be(:users)
    expect(Test::Users.relation_name.relation).to be(:users)
  end

  it 'sets dataset and respects custom register_as' do
    class Test::Users < ROM::Relation[:memory]
      schema(:users, as: :test_users) do
        attribute :id, Types::Integer
        attribute :name, Types::String
      end
    end

    expect(Test::Users.relation_name.dataset).to be(:users)
    expect(Test::Users.relation_name.relation).to be(:test_users)
  end

  it 'raises error when schema_class is missing' do
    class Test::Users < ROM::Relation[:memory]
      schema_class nil
    end

    expect { Test::Users.schema(:test) {} }
      .to raise_error(ROM::MissingSchemaClassError, 'Test::Users relation is missing schema_class')
  end

  describe '#schema' do
    it 'returns defined schema' do
      class Test::Users < ROM::Relation[:memory]
        schema do
          attribute :id, Types::Integer.meta(primary_key: true)
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

      schema = Test::Users.schema_proc.call

      expect(
        schema[:admin]
      ).to eql(ROM::Attribute.new(
                 ROM::Types::Bool.meta(source: ROM::Relation::Name[:test_users]),
                 name: :admin
               ))
    end

    it 'raises an error on double definition' do
      expect {
        class Test::Users < ROM::Relation[:memory]
          schema do
            attribute :id, Types::Integer.meta(primary_key: true)
            attribute :name, Types::String
            attribute :id, Types::Integer
          end
        end

        Test::Users.schema_proc.call
      }.to raise_error(ROM::AttributeAlreadyDefinedError,
                       /:id already defined/)
    end

    it 'builds optional read types automatically' do
      to_s = ROM::Types::String.constructor(:to_s.to_proc)
      to_s_on_read = ROM::Types::String.meta(read: to_s)

      Test::Users = Class.new(ROM::Relation[:memory]) do
        schema do
          attribute :id, ROM::Types::Integer.meta(primary_key: true)
          attribute :name, to_s_on_read.optional
        end
      end

      schema = Test::Users.schema_proc.call

      expect(schema[:name].type)
        .to eql(
          to_s_on_read.optional.meta(
            source: ROM::Relation::Name[:rom_memory_relation],
            read: to_s.optional
          )
        )
    end
  end

  describe '#schema_proc' do
    it 'is idempotent' do
      class Test::Users < ROM::Relation[:memory]
        schema do
          attribute :id, Types::Integer.meta(primary_key: true)
          attribute :name, Types::String
          attribute :admin, Types::Bool
        end
      end

      expect(Test::Users.schema_proc.call.finalize_attributes!)
        .to eql(Test::Users.schema_proc.call.finalize_attributes!)
    end
  end

  describe '#with' do
    it 'resets input and output schemas' do
      class Test::Users < ROM::Relation[:memory]
        schema do
          attribute :id, Types::Integer.meta(primary_key: true), read: Types::Integer
          attribute :name, Types::String
        end
      end

      users = Test::Users.new([])
      projected = users.with(schema: users.schema.project(:id))

      expect(projected.input_schema.(id: 1, name: 'Jane')).to eql(id: 1)
      expect(projected.output_schema.(id: 1, name: 'Jane')).to eql(id: 1)
    end
  end
end
