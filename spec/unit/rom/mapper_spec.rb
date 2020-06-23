# frozen_string_literal: true

require "dry/equalizer"
require "ostruct"

RSpec.describe ROM::Mapper do
  subject(:mapper) { mapper_class.build }

  let(:mapper_class) do
    user_model = self.user_model

    Class.new(ROM::Mapper) do
      attribute :id
      attribute :name
      model user_model
    end
  end

  let(:relation) do
    [{id: 1, name: "Jane"}, {id: 2, name: "Joe"}]
  end

  let(:user_model) do
    Class.new(OpenStruct) { include Dry::Equalizer(:id, :name) }
  end

  let(:jane) { user_model.new(id: 1, name: "Jane") }
  let(:joe) { user_model.new(id: 2, name: "Joe") }

  describe ".registry" do
    it "builds mapper class registry for base and virtual relations" do
      users = Class.new(ROM::Mapper) { relation(:users) }
      entity = Class.new(ROM::Mapper) do
        relation(:users)
        register_as(:entity)
      end
      active = Class.new(users) { relation(:active) }
      admins = Class.new(users) { relation(:admins) }
      custom = Class.new(users) { register_as(:custom) }

      registry = ROM::Mapper.registry([users, entity, active, admins, custom])

      expect(registry).to eql(
        users: {
          users: users.build,
          entity: entity.build,
          active: active.build,
          admins: admins.build,
          custom: custom.build
        }
      )
    end
  end

  describe ".relation" do
    it "inherits from parent" do
      base = Class.new(ROM::Mapper) { relation(:users) }
      virt = Class.new(base)

      expect(virt.relation).to be(:users)
      expect(virt.base_relation).to be(:users)
    end

    it "allows overriding" do
      base = Class.new(ROM::Mapper) { relation(:users) }
      virt = Class.new(base) { relation(:active) }

      expect(virt.relation).to be(:active)
      expect(virt.base_relation).to be(:users)
    end
  end

  describe "#each" do
    it "yields all mapped objects" do
      result = []

      mapper.call(relation).each do |tuple|
        result << tuple
      end

      expect(result).to eql([jane, joe])
    end
  end
end
