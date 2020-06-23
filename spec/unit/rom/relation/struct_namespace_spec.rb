# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation, "#struct_namespace" do
  let(:dataset) do
    [{id: 1, name: "Jane"}]
  end

  before do
    module Test::Entities
      class User < ROM::Struct
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

  context "setting at runtime" do
    subject(:relation) do
      Class.new(ROM::Relation) do
        schema(:users) do
          attribute :id, ROM::Types::Integer
          attribute :name, ROM::Types::String
        end
      end.new(dataset, auto_struct: true)
    end

    it "returns a new relation configured for the provided struct namespace" do
      users = relation.struct_namespace(Test::Entities)

      expect(users.first).to be_my_user
    end

    it "returns a new relation configured for the provided struct namespace and aliased relation" do
      users = relation.as(:admins).struct_namespace(Test::Entities)

      expect(users.first).to be_admin
    end

    it "allows switching namespaces at runtime" do
      entities = relation.struct_namespace(Test::Entities)
      models = relation.struct_namespace(Test::Models)

      expect(entities.first).to be_my_user
      expect(models.first).to be_super_user
    end
  end

  context "using default setting" do
    subject(:relation) do
      Class.new(ROM::Relation) do
        struct_namespace Test::Entities

        schema(:users) do
          attribute :id, ROM::Types::Integer
          attribute :name, ROM::Types::String
        end
      end.new(dataset, auto_struct: true)
    end

    it "returns a new relation configured for the provided struct namespace" do
      expect(relation.first).to be_my_user
    end

    context "using inheritance" do
      let(:admins) do
        Class.new(relation.class) do
          schema(:users, as: :admins) do
            attribute :id, ROM::Types::Integer
            attribute :name, ROM::Types::String
          end
        end.new(dataset, auto_struct: true)
      end

      it "inherits struct namespace and uses custom alias" do
        expect(admins.first).to be_admin
      end
    end
  end
end
