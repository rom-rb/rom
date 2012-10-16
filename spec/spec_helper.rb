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

  def mock_mapper(model_class)
    Class.new(DataMapper::Mapper::Relation::Base) do
      model      model_class
      repository DataMapper::Inflector.tableize(model_class.name)

      def self.name
        "#{model.name}Mapper"
      end
    end
  end

  def mock_relation(name, header = [])
    Veritas::Relation::Base.new(name, header)
  end

  def mock_relationship(name, attributes = {})
    OpenStruct.new({ :name => name }.merge(attributes))
  end

  def clear_mocked_models
    @_mocked_models.each do |name|
      Object.send(:remove_const, name) if Object.const_defined?(name)
    end
  end
end

Dir[File.expand_path('../shared/**/*.rb', __FILE__)].each { |file| require file }

include DataMapper
