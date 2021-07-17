# frozen_string_literal: true

require "rom/relation"

RSpec.describe ROM::Relation do
  describe "#adapter" do
    it "returns adapter inferred from parent class" do
      module Test
        class Users < ROM::Relation[:memory]
        end
      end

      relation = Test::Users.new

      expect(relation.adapter).to be(:memory)
    end
  end

  describe "#name" do
    it "returns name inferred from demodulized class name" do
      module Test
        class Users < ROM::Relation[:memory]
        end
      end

      relation = Test::Users.new([])

      expect(relation.name.dataset).to be(:users)
      expect(relation.name.relation).to be(:users)
    end

    it "returns name inferred from schema" do
      module Test
        class Users < ROM::Relation[:memory]
          schema(:people)
        end
      end

      relation = Test::Users.new([])

      expect(relation.name.dataset).to be(:people)
      expect(relation.name.relation).to be(:users)
    end

    it "returns name inferred from schema with an alias" do
      module Test
        class Users < ROM::Relation[:memory]
          schema(:users, as: :people)
        end
      end

      relation = Test::Users.new([])

      expect(relation.name.dataset).to be(:users)
      expect(relation.name.relation).to be(:people)
    end

    it "returns name that's explicitly configured through custom id" do
      module Test
        class Users < ROM::Relation[:memory]
          config.component.id = :people
        end
      end

      relation = Test::Users.new([])

      expect(relation.name.dataset).to be(:users)
      expect(relation.name.relation).to be(:people)
    end

    it "returns name that's explicitly configured through custom dataset" do
      module Test
        class Users < ROM::Relation[:memory]
          config.component.dataset = :people
        end
      end

      relation = Test::Users.new([])

      expect(relation.name.dataset).to be(:people)
      expect(relation.name.relation).to be(:users)
    end

    it "returns name that's explicitly configured through custom id and dataset" do
      module Test
        class Users < ROM::Relation[:memory]
          config.component.id = :people
          config.component.dataset = :humans
        end
      end

      relation = Test::Users.new([])

      expect(relation.name.dataset).to be(:humans)
      expect(relation.name.relation).to be(:people)
    end
  end

  describe "#dataset" do
    it "returns dataset inferred from gateway" do
      module Test
        class Users < ROM::Relation[:memory]
        end
      end

      relation = Test::Users.new

      expect(relation.dataset).to be_empty
    end
  end

  describe "#schema" do
    it "returns schema inferred from demodulized class name" do
      module Test
        class Users < ROM::Relation[:memory]
        end
      end

      relation = Test::Users.new([])

      expect(relation.name.dataset).to be(:users)
      expect(relation.name.relation).to be(:users)

      expect(relation.schema.name.dataset).to be(:users)
      expect(relation.schema.name.relation).to be(:users)
    end

    it "returns schema that's explicitly defined" do
      module Test
        class Users < ROM::Relation[:memory]
          schema(:people)
        end
      end

      relation = Test::Users.new([])

      expect(relation.name.dataset).to be(:people)
      expect(relation.name.relation).to be(:users)

      expect(relation.schema.name.dataset).to be(:people)
      expect(relation.schema.name.relation).to be(:users)
    end
  end
end
