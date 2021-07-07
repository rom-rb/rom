# frozen_string_literal: true

require "rom/components"
require "rom/schema"

RSpec.describe ROM::Components do
  shared_context "component provider" do
    it "enables DSL methods for specified component types" do
      expect(provider).to respond_to(:dataset)
      expect(provider).to respond_to(:schema)
    end

    it "skips non-specified DSL methods" do
      expect(provider).to_not respond_to(:relation)
    end

    it "can use the DSL" do
      schema = provider.schema(:users)

      expect(schema).to be_a(ROM::Components::Schema)
      expect(schema.id).to be(:users)
      expect(schema.gateway).to be(:default)
    end

    it "provides a working component" do
      schema = provider.schema(:users)

      provider.with_configuration(ROM::Runtime::Configuration.new) do
        expect(schema.build).to be_a(schema_class)
      end
    end
  end

  context "with a class" do
    subject(:provider) do
      Test::Repo
    end

    let(:schema_class) do
      provider.schema_class
    end

    before do
      module Test
        class Repo
          extend ROM.Components(:dataset, :schema)

          def self.adapter
            :memory
          end

          def self.gateway
            :default
          end

          def self.schema_class
            ROM::Schema
          end

          def self.schema_inferrer
            ROM::Schema::DEFAULT_INFERRER
          end

          def self.schema_attr_class
            ROM::Attribute
          end

          def self.schema_dsl
            ROM::Schema::DSL
          end

          def self.infer_option(option, component:)
            send(option)
          end
        end
      end
    end

    include_context "component provider"
  end

  context "with an instance" do
    subject(:provider) do
      Test::Repo.new
    end

    let(:schema_class) do
      provider.config.schema.schema_class
    end

    before do
      module Test
        class Repo
          include ROM.Components(:dataset, :schema)
          include Dry::Configurable

          setting :adapter, :memory
          setting :gateway, :default

          setting :schema do
            setting :schema_class, ROM::Schema
            setting :inferrer, ROM::Schema::DEFAULT_INFERRER
            setting :attr_class, ROM::Attribute
            setting :dsl_class, ROM::Schema::DSL
          end
        end
      end
    end

    include_context "component provider"
  end
end
