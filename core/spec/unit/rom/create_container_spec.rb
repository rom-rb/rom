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

    it "raises an error when registering same mapper twice for the same relation" do
      configuration

      users_mapper = Class.new(ROM::Mapper) do
        register_as :users
        relation :users
      end

      users_mapper_2 = Class.new(ROM::Mapper) do
        register_as :users
        relation :users
      end

      configuration.register_mapper(users_mapper)
      configuration.register_mapper(users_mapper_2)

      expect { container }.to raise_error(
                                ROM::MapperAlreadyDefinedError, /register_as :users/
                              )
    end

    it "doesn't raise an error when registering same mapper twice for different relation" do
      configuration

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
      configuration

      users_mapper = Class.new(ROM::Mapper) do
        register_as :users
        relation :users
      end

      user_mapper_no_relation = Class.new(ROM::Mapper) do
        register_as :users
      end

      configuration.register_mapper(users_mapper)
      configuration.register_mapper(user_mapper_no_relation)

      expect { container }.not_to raise_error
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
      expect(container.commands).to eql(ROM::Registry.build)
    end
  end
end
