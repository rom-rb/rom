require 'spec_helper'

RSpec.describe ROM::CreateContainer, '#finalize' do
  describe '#finalize' do
    include_context 'container'

    it 'can register multiple relations with same dataset' do
      configuration

      apples = Class.new(ROM::Relation[:memory]) do
        schema(:fruits, as: :apples) { }

        def apple?
          true
        end
      end

      oranges = Class.new(ROM::Relation[:memory]) do
        schema(:fruits, as: :oranges) { }

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
      configuration

      users = Class.new(ROM::Relation[:memory]) do
        schema(:guests, as: :users) { }
      end

      users2 = Class.new(ROM::Relation[:memory]) do
        schema(:admins, as: :users) { }
      end

      configuration.register_relation(users)
      configuration.register_relation(users2)

      expect { container }.to raise_error(
                                ROM::RelationAlreadyDefinedError, /name :users/
                              )
    end

    it "raises an error when registering same mapper twice" do
      configuration

      users_mapper = Class.new(ROM::Mapper) do
        register_as :users
        relation :users
        attribute :name
        attribute :email
      end

      users_mapper_2 = Class.new(ROM::Mapper) do
        register_as :users
        relation :users
        attribute :name
        attribute :email
      end

      configuration.register_mapper(users_mapper)
      configuration.register_mapper(users_mapper_2)

      expect { container }.to raise_error(
                                ROM::MapperAlreadyDefinedError, /register_as :users/
                              )
    end
  end

  context 'empty setup' do
    let(:configuration) { ROM::Configuration.new({}) }
    let(:container) { ROM.container(configuration) }

    it 'builds empty gateways' do
      expect(container.gateways).to eql({})
    end

    it 'builds empty relations' do
      expect(container.relations).to eql(ROM::RelationRegistry.new)
    end

    it 'builds empty mappers' do
      expect(container.mappers).to eql(ROM::Registry.new)
    end

    it 'builds empty commands' do
      expect(container.commands).to eql(ROM::Registry.new)
    end
  end
end
