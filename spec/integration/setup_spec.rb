require 'rom/memory'

RSpec.describe 'Setting up rom suite' do
  subject(:rom) do
    ROM.container(:memory) do |config|
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

  it 'works' do
    expect(rom.relations[:users]).to be_instance_of(Test::Users)
  end

  describe 'configuring plugins for schemas' do
    after do
      ROM.plugin_registry[:schema]
        .adapter(:default)
        .fetch(:timestamps)
        .instance_variable_set(:@config, nil)
    end

    let(:configuration) { ROM::Configuration.new(:memory) }
    let(:container) { ROM.container(configuration) }

    subject(:schema) { container.relations[:users].schema }

    it 'allows setting timestamps in all schemas' do
      configuration.plugin(:memory, schemas: :timestamps)

      configuration.relation(:users)

      expect(schema.to_h.keys).to eql(%i[created_at updated_at])
    end

    it 'extends schema dsl' do
      configuration.plugin(:memory, schemas: :timestamps)

      configuration.relation(:users) do
        schema do
          timestamps :created_on, :updated_on
        end
      end

      expect(schema.to_h.keys).to eql(%i[created_on updated_on])
    end

    it 'accepts options' do
      configuration.plugin(:memory, schemas: :timestamps) do |p|
        p.attributes = %i[created_on updated_on]
      end

      configuration.relation(:users)

      expect(schema.to_h.keys).to eql(%i[created_on updated_on])
    end
  end
end
