require 'devtools'

Devtools.init_spec_helper

require 'rom-session'

require 'axiom'
require 'rom-relation'
require 'rom-mapper'
require 'rom/support/axiom/adapter/in_memory'

require 'bogus/rspec'

include ROM

def mock_model(*attributes)
  Class.new {
    include Equalizer.new(*attributes)

    attributes.each { |attribute| attr_accessor attribute }

    def initialize(attrs)
      attrs.each { |name, value| send("#{name}=", value) }
    end
  }
end

# FIXME: this monkey patching will be eventually moved to rom-relation
class Environment
  attr_reader :registry

  def [](name)
    registry[name]
  end

  def load_schema(schema)
    @registry = {}

    schema.each do |repository_name, relations|
      relations.each do |relation|
        name            = relation.name.to_sym
        @registry[name] = repository(repository_name).register(relation).get(name)
      end
    end

    self
  end
end

class Mapper
  public :loader, :dumper

  def self.build(attributes, model)
    header = Mapper::Header.coerce(attributes)
    new(Mapper::Loader.new(header, model), Mapper::Dumper.new(header, model))
  end
end

class Relation
  public :mapper

  def inject_mapper(new_mapper)
    self.class.new(relation, new_mapper)
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

TEST_ENV = Environment.coerce(:test => 'in_memory://test')
TEST_ENV.load_schema(SCHEMA)
