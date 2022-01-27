# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#schema" do
  subject(:relation) do
    Class.new(ROM::Relation) do
      config.component.id = :users

      schema(:users) do
        attribute :id, Types::String
      end
    end.new([])
  end

  it "returns named schema" do
    expect(relation.schema).to_not be_nil
    expect(relation.schema[:id].meta[:source]).to eql(ROM::Relation::Name[:users])
  end

  it "uses custom schema dsl" do
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

    schema = Test::Users.new([]).schema

    expect(schema[:admin]).to eql(
      ROM::Attribute.new(
        ROM::Types::Bool.meta(source: ROM::Relation::Name[:users]),
        name: :admin
      )
    )
  end
end
