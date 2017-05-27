require 'spec_helper'

RSpec.describe ROM::CreateContainer do
  describe '#finalize' do
    include_context 'container'

    context 'with gateway that supports schema inferring' do
      it 'builds relation from inferred schema' do
        repo = configuration.gateways[:default]
        dataset = double('dataset')

        allow(repo).to receive(:schema).and_return([:users])
        allow(repo).to receive(:dataset).with(:users).and_return(dataset)

        expect(container.relations.users.dataset).to be(dataset)
      end

      it 'skips inferring a relation when there is a defined one already' do
        repo = configuration.gateways[:default]
        dataset_double = double('dataset')

        allow(repo).to receive(:schema).and_return([:users])
        allow(repo).to receive(:dataset).with(:users).and_return(dataset_double)

        users = Class.new(ROM::Relation[:memory]) do
          register_as :users
          dataset :users
        end

        configuration.register_relation(users)

        expect { container }.not_to raise_error

        expect(container.relations.users).to be_instance_of(users)
      end

      it 'skips inferring when it is turned off for the adapter' do
        configuration.config.gateways.default.infer_relations = false

        repo = configuration.default

        expect(repo).not_to receive(:schema)

        container
      end

      it 'infers configured relations' do
        configuration.config.gateways.default.inferrable_relations = [:test_tasks]

        repo = configuration.default
        dataset = double('dataset')

        allow(repo).to receive(:schema).and_return([:test_tasks, :test_users])

        expect(repo).to receive(:dataset).with(:test_tasks).and_return(dataset)
        expect(repo).to_not receive(:dataset).with(:test_users)

        expect(container.relations.elements.key?(:test_users)).to be(false)
        expect(container.relations[:test_tasks]).to be_kind_of(ROM::Memory::Relation)
        expect(container.relations[:test_tasks].dataset).to be(dataset)
      end

      it 'skip inferring blacklisted relations' do
        configuration.config.gateways.default.not_inferrable_relations = [:test_users]

        repo = configuration.default
        dataset = double('dataset')

        allow(repo).to receive(:schema).and_return([:test_tasks, :test_users])

        expect(repo).to receive(:dataset).with(:test_tasks).and_return(dataset)
        expect(repo).to_not receive(:dataset).with(:test_users)

        expect(container.relations.elements.key?(:test_users)).to be(false)
        expect(container.relations[:test_tasks]).to be_kind_of(ROM::Memory::Relation)
        expect(container.relations[:test_tasks].dataset).to be(dataset)
      end

      it 'can register multiple relations with same dataset' do
        configuration

        apples = Class.new(ROM::Relation[:memory]) do
          dataset :fruits
          register_as :apples

          def apple?
            true
          end
        end

        oranges = Class.new(ROM::Relation[:memory]) do
          dataset :fruits
          register_as :oranges

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

      it "raises an error when registering relations with the same `register_as`" do
        configuration

        users = Class.new(ROM::Relation[:memory]) do
          dataset :guests
          register_as :users
        end

        users2 = Class.new(ROM::Relation[:memory]) do
          dataset :admins
          register_as :users
        end

        configuration.register_relation(users)
        configuration.register_relation(users2)

        expect { container }.to raise_error(
          ROM::RelationAlreadyDefinedError, /register_as :users/
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
end
