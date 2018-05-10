require 'rom/memory'
require 'rom/support/inflector'

RSpec.describe 'Setting up rom suite' do
  subject(:rom) do
    ROM.container(:memory) do |config|
      config.register_relation(Test::Users)
    end
  end

  before do
    class Test::Users < ROM::Relation[:memory]
      schema(:users) do
        attribute :id, Types::Int
        attribute :name, Types::String
      end
    end
  end

  it 'works' do
    expect(rom.relations[:users]).to be_instance_of(Test::Users)
  end

  describe 'configuring plugins for schemas' do
    after do
      ROM.plugin_registry
         .schemas.adapter(:default)
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

  describe 'configuring the inflector' do
    around(:each) do |ex|
      begin
        old_inflector = ROM.inflector
        ex.run
      ensure
        ROM.inflector_implementation = old_inflector
      end
    end

    it 'can be configured by setting the inflector_implementation' do
      ROM.inflector_implementation = Dry::Inflector.new do |i|
        i.plural(/criterion\z/i, 'criteria')
      end

      expect(ROM.inflector.pluralize('criterion')).to eql('criteria')
    end

    it 'is accessible via ROM::Inflector' do
      expect(ROM::Inflector).to eql(ROM.inflector)
    end
  end
end
