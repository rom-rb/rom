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

    schema = Test::Users.schema_proc.call.finalize_attributes!

    relation_name = ROM::Relation::Name[:test_users]

    schema = ROM::Memory::Schema.define(
      ROM::Relation::Name.new(:test_users),
      attributes: [
        ROM::Memory::Types::Int.meta(primary_key: true, name: :id, source: relation_name),
        ROM::Memory::Types::String.meta(name: :name, source: relation_name),
        ROM::Memory::Types::Bool.meta(name: :admin, source: relation_name)
      ]
    ).finalize_attributes!

    expect(schema.primary_key).to eql([schema[:id]])

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
        attribute :id, Types::Int
        attribute :date, Types::Coercible::String, read: Test::Types::CoercibleDate
      end
    end

    schema = Test::Users.schema_proc.call

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

    schema = Test::Users.schema_proc.call.finalize_attributes!

    expect(schema.primary_key).to eql([schema[:name], schema[:email]])
  end

  it 'allows setting foreign keys' do
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

  it 'sets register_as and dataset' do
    class Test::Users < ROM::Relation[:memory]
      schema(:users) do
        attribute :id, Types::Int
        attribute :name, Types::String
      end
    end

    expect(Test::Users.relation_name.dataset).to be(:users)
    expect(Test::Users.relation_name.relation).to be(:users)
  end

  it 'sets dataset and respects custom register_as' do
    class Test::Users < ROM::Relation[:memory]
      schema(:users, as: :test_users) do
        attribute :id, Types::Int
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

      schema = Test::Users.schema_proc.call

      expect(schema[:admin]).to eql(ROM::Types::Bool.meta(name: :admin, source: ROM::Relation::Name[:test_users]))
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

        Test::Users.schema_proc.call
      }.to raise_error(ROM::Schema::AttributeAlreadyDefinedError,
                       /:id already defined/)
    end
  end
end
