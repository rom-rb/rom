if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'spec:unit'

    add_filter 'config'
    add_filter 'lib/rom/support'
    add_filter 'spec'
  end
end

require 'devtools/spec_helper'

require 'rom-session'

require 'axiom'
require 'rom-relation'
require 'rom-mapper'
require 'rom/support/axiom/adapter/memory'

require 'bogus/rspec'

include ROM

class ROM::Relation
  def update(object, original_tuple)
    new(relation.delete([original_tuple]).insert([mapper.dump(object)]))
  end
end

def mock_model(*attributes)
  Class.new {
    include Equalizer.new(*attributes)

    attributes.each { |attribute| attr_accessor attribute }

    def initialize(attrs = {})
      attrs.each { |name, value| send("#{name}=", value) }
    end
  }
end

class ROM::Mapper
  def self.build(header, model)
    new(Mapper::Loader::ObjectBuilder.new(header, model), Mapper::Dumper.new(header, model))
  end
end

SCHEMA = Schema.build do
  base_relation :users do
    repository :test

    attribute :id,   Integer
    attribute :name, String

    key :id
  end
end

TEST_ENV = Environment.coerce(:test => 'memory://test')
TEST_ENV.load_schema(SCHEMA)
