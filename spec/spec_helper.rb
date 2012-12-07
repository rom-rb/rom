require 'pp'
require 'ostruct'
require 'dm-mapper'
require 'virtus'

require 'data_mapper/engine/veritas'

require 'rspec'

module SpecHelper
  def self.mocks
    @mocks
  end

  def self.reset_mocks!
    @mocks = { :models => [], :mappers => [] }
  end

  def self.clear_mocks!
    @mocks[:models].each do |name|
      #puts "REMOVING: #{name}"
      Object.send(:remove_const, name) if Object.const_defined?(name)
    end

    @mocks[:mappers].each do |name|
      #puts "REMOVING: #{name}"
      Object.send(:remove_const, name) if Object.const_defined?(name)
    end

    DataMapper::Mapper.instance_variable_set(:@descendants, [])
    DataMapper::Relation::Mapper.instance_variable_set(:@descendants, [])

    reset_mocks!
  end
end

RSpec.configure do |config|
  config.before(:each) do
    if example.metadata[:example_group][:file_path] =~ /unit/
      SpecHelper.reset_mocks!

      # TODO Find out why this is necessary since renaming RelationRegistry => Relation
      DataMapper::Mapper.instance_variable_set(:@registry, nil)
    end
  end

  config.after(:each) do
    if example.metadata[:example_group][:file_path] =~ /unit/
      SpecHelper.clear_mocks!
    end
  end

  def subclass(name = nil)
    Class.new(described_class) do
      define_singleton_method(:name) { "#{name}" }
      yield if block_given?
    end
  end

  def mock_model(type)
    if Object.const_defined?(type)
      Object.const_get(type)
    else
      SpecHelper.mocks[:models] << type
      Object.const_set(type, Class.new(OpenStruct))
    end
  end

  def mock_mapper(model_class, attributes = [], relationships = [])
    klass = Class.new(DataMapper::Relation::Mapper) do
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


    SpecHelper.mocks[:mappers] << klass.name.to_sym

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

  def mock_join_definition(left_relation, right_relation, left_keys, right_keys)
    left  = Relationship::JoinDefinition::Side.new(left_relation,  left_keys)
    right = Relationship::JoinDefinition::Side.new(right_relation, right_keys)
    Relationship::JoinDefinition.new(left, right)
  end

  def unary_aliases(field_map, original_aliases)
    Relation::Graph::Node::Aliases::Unary.new(field_map, original_aliases)
  end

  class TestEngine < DataMapper::Engine::Veritas::Engine
    def initialize(uri)
      @relations = DataMapper::Relation::Graph.new(self)
    end
  end

  TEST_ENGINE = TestEngine.new('db://localhost/test')
  DataMapper.engines[:test] = TEST_ENGINE
end

Dir[File.expand_path('../shared/**/*.rb', __FILE__)].each { |file| require file }

include DataMapper
