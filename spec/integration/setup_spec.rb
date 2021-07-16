# frozen_string_literal: true

require "rom/memory"

RSpec.describe "Setting up rom suite" do
  subject(:rom) do
    ROM.runtime(:memory) do |config|
      config.register_relation(Test::Users)
    end
  end

  before do
    class Test::Users < ROM::Relation[:memory]
      schema(:users) do
        attribute :id, Types::Integer
        attribute :name, Types::String
      end
    end
  end

  it "works" do
    expect(rom.relations[:users]).to be_instance_of(Test::Users)
  end

  describe "configuring plugins for schemas" do
    let(:configuration) { ROM::Runtime.new(:memory) }
    let(:container) { ROM.runtime(configuration) }

    subject(:schema) { container.relations[:users].schema }

    it "allows setting timestamps in all schemas" do
      configuration.plugin(:memory, schemas: :timestamps)

      configuration.relation(:users)

      expect(schema.to_h.keys).to eql(%i[created_at updated_at])
    end

    it "extends schema dsl" do
      configuration.plugin(:memory, schemas: :timestamps)

      configuration.relation(:users) do
        schema do
          timestamps :created_on, :updated_on
        end
      end

      expect(schema.to_h.keys).to eql(%i[created_on updated_on])
    end

    it "accepts options" do
      configuration.plugin(:memory, schemas: :timestamps) do |p|
        p.attributes = %i[created_on updated_on]
      end

      configuration.relation(:users)

      expect(schema.to_h.keys).to eql(%i[created_on updated_on])
    end
  end
end
