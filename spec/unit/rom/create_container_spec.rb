# frozen_string_literal: true

require "spec_helper"

RSpec.describe ROM::Global, "#container" do
  context "with configuration" do
    include_context "container"

    it "can register multiple relations with same dataset" do
      apples = Class.new(ROM::Relation[:memory]) do
        schema(:fruits, as: :apples)

        def apple?
          true
        end
      end

      oranges = Class.new(ROM::Relation[:memory]) do
        schema(:fruits, as: :oranges)

        def orange?
          true
        end
      end

      configuration.register_relation(apples)
      configuration.register_relation(oranges)

      expect(container.relations.apples).to be_apple
      expect(container.relations.oranges).to be_orange
      expect(container.relations.apples).to_not eq(container.relations.oranges)
    end

    it "raises an error when registering relations with the same `name`" do
      users = Class.new(ROM::Relation[:memory]) do
        schema(:guests, as: :users) {}
      end

      users2 = Class.new(ROM::Relation[:memory]) do
        schema(:admins, as: :users) {}
      end

      expect { configuration.register_relation(users, users2) }.to raise_error(
        ROM::RelationAlreadyDefinedError, /\+relations\.users\+ is already defined/
      )
    end

    it "raises an error when registering same mapper twice for the same relation" do
      users = Class.new(ROM::Relation[:memory]) do
        schema(:users) {}
      end

      users_mapper = Class.new(ROM::Mapper) do
        register_as :users
        relation :users
      end

      users_mapper_2 = Class.new(ROM::Mapper) do
        register_as :users
        relation :users
      end

      configuration.register_relation(users)

      expect { configuration.register_mapper(users_mapper, users_mapper_2) }.to raise_error(
        ROM::MapperAlreadyDefinedError, /\+mappers\.users\.users\+ is already defined/
      )
    end

    it "doesn't raise an error when registering same mapper twice for different relation" do
      users_mapper = Class.new(ROM::Mapper) do
        register_as :users
        relation :users
      end

      admin_users_mapper = Class.new(ROM::Mapper) do
        register_as :users
        relation :admin_users
      end

      configuration.register_mapper(users_mapper)
      configuration.register_mapper(admin_users_mapper)

      expect { container }.not_to raise_error
    end

    it "doesn't raise an error when registering same mapper twice for different relation when no relation specify" do
      users_mapper = Class.new(ROM::Mapper) do
        register_as :users
        relation :users
      end

      others_mapper = Class.new(ROM::Mapper) do
        register_as :users
        relation :others
      end

      configuration.register_mapper(users_mapper)
      configuration.register_mapper(others_mapper)

      expect { container }.not_to raise_error
    end
  end

  context "empty setup" do
    let(:configuration) { ROM::Configuration.new({}) }
    let(:container) { ROM.container(configuration) }

    it "builds empty gateways" do
      expect(container.gateways.keys).to be_empty
    end

    it "builds empty relations" do
      expect(container.relations).to be_empty
    end

    it "builds empty mappers" do
      expect(container.mappers).to be_empty
    end

    it "builds empty commands" do
      expect(container.commands).to be_empty
    end
  end
end
