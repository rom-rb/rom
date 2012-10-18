require 'ostruct'
require 'dm-mapper'

begin
  require 'rspec'  # try for RSpec 2
rescue LoadError
  require 'spec'   # try for RSpec 1
  RSpec = Spec::Runner
end

RSpec.configure do |config|
  config.before(:all, :type => :unit) do
    @_mocked_models = []
  end

  config.after(:each, :type => :unit) do
    clear_mocked_models
  end

  def mock_model(type)
    @_mocked_models << type
    Object.const_set(type, Class.new(OpenStruct))
  end

  def mock_mapper(model_class, attributes = [])
    klass = Class.new(DataMapper::Mapper::Relation::Base) do
      model         model_class
      repository    :test
      relation_name Inflector.tableize(model_class.name)

      def self.name
        "#{model.name}Mapper"
      end
    end

    attributes.each do |attribute|
      klass.attributes << attribute
    end

    klass
  end

  def mock_relation(name, header = [])
    Veritas::Relation::Base.new(name, header)
  end

  def mock_relationship(name, attributes = {})
    OpenStruct.new({ :name => name }.merge(attributes))
  end

  def mock_connector(attributes)
    OpenStruct.new(attributes)
  end

  def mock_alias_set(prefix, attributes)
    attribute_set = Mapper::AttributeSet.new

    attributes.each do |name, type|
      attribute_set << Mapper::Attribute.build(name, :type => type)
    end

    AliasSet.new(prefix, attribute_set)
  end

  class TestEngine < DataMapper::Engine::VeritasEngine
    def initialize(uri)
      @relations = DataMapper::RelationRegistry.new(self)
    end
  end

  TEST_ENGINE = TestEngine.new('db://localhost/test')
  DataMapper.engines[:test] = TEST_ENGINE

  def clear_mocked_models
    @_mocked_models.each do |name|
      Object.send(:remove_const, name) if Object.const_defined?(name)
    end
  end
end

Dir[File.expand_path('../shared/**/*.rb', __FILE__)].each { |file| require file }

include DataMapper
