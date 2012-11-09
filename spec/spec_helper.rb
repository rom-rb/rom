require 'ostruct'
require 'dm-mapper'
require 'virtus'

begin
  require 'rspec'  # try for RSpec 2
rescue LoadError
  require 'spec'   # try for RSpec 1
  RSpec = Spec::Runner
end

require 'monkey_patches'

RSpec.configure do |config|
  config.before(:all, :type => :unit) do
    # FIXME: remove this when we upgrade to rspec2
    unless self.instance_variable_get(:"@_proxy").location =~ /integration/
      @_mocked_models  = []
      @_mocked_mappers = []
    end
  end

  config.after(:each, :type => :unit) do
    # FIXME: remove this when we upgrade to rspec2
    unless self.instance_variable_get(:"@_proxy").location =~ /integration/
      clear_mocked_mappers
      clear_mocked_models
    end
  end

  def subclass(name = nil)
    Class.new(described_class) do
      define_singleton_method(:name) { "#{name}" }
      yield if block_given?
    end
  end

  def mock_model(type)
    @_mocked_models << type
    Object.const_set(type, Class.new(OpenStruct))
  end

  def mock_mapper(model_class, attributes = [], relationships = [])
    klass = Class.new(DataMapper::Mapper::Relation) do
      model         model_class
      repository    :test
      relation_name Inflector.tableize(model_class.name).to_sym

      def self.name
        "#{model.name}Mapper"
      end
    end

    attributes.each do |attribute|
      klass.attributes << attribute
    end

    relationships.each do |relationship|
      klass.relationships << relationship
    end

    @_mocked_mappers << klass.name.to_sym

    klass
  end

  def mock_attribute(name, type, options = {})
    Mapper::Attribute.build(name, options.merge(:type => type))
  end

  def mock_relation(name, header = [])
    Veritas::Relation::Base.new(name, header)
  end

  def mock_relationship(name, attributes = {})
    Relationship::OneToMany.new(name, attributes[:source_model], attributes[:target_model], attributes)
  end

  def mock_connector(attributes)
    OpenStruct.new(attributes)
  end

  def mock_node(name)
    OpenStruct.new(:name => name)
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

  def clear_mocked_mappers
    @_mocked_mappers.each do |name|
      Object.send(:remove_const, name) if Object.const_defined?(name)
    end
    DataMapper::Mapper.instance_variable_set(:@descendants, [])
    DataMapper::Mapper::Relation.instance_variable_set(:@descendants, [])
  end
end

Dir[File.expand_path('../shared/**/*.rb', __FILE__)].each { |file| require file }

include DataMapper
