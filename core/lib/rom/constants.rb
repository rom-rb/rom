require 'dry/core/constants'

# Constants and errors common in the whole library
module ROM
  include Dry::Core::Constants

  AdapterLoadError = Class.new(StandardError)

  class AdapterNotPresentError < StandardError
    def initialize(adapter, component)
      super(
        "Failed to find #{component} class for #{adapter} adapter. " \
        "Make sure ROM setup was started and the adapter identifier is correct."
      )
    end
  end

  EnvAlreadyFinalizedError = Class.new(StandardError)
  RelationAlreadyDefinedError = Class.new(StandardError)
  MapperAlreadyDefinedError = Class.new(StandardError)
  NoRelationError = Class.new(StandardError)
  CommandError = Class.new(StandardError)
  KeyMissing = Class.new(ROM::CommandError)
  TupleCountMismatchError = Class.new(CommandError)
  UnknownPluginError = Class.new(StandardError)
  UnsupportedRelationError = Class.new(StandardError)
  MissingAdapterIdentifierError = Class.new(StandardError)

  class ElementNotFoundError < KeyError
    def initialize(key, registry)
      super(set_message(key, registry))
    end

    def set_message(key, registry)
      "#{key.inspect} doesn't exist in #{registry.class.name} registry"
    end
  end

  MapperMissingError = Class.new(ElementNotFoundError)

  CommandNotFoundError = Class.new(ElementNotFoundError) do
    def set_message(key, registry)
      "There is no :#{key} command for :#{registry.relation_name} relation"
    end
  end

  MissingSchemaClassError = Class.new(StandardError) do
    def initialize(klass)
      super("#{klass.inspect} relation is missing schema_class")
    end
  end

  MissingSchemaError = Class.new(StandardError) do
    def initialize(klass)
      super("#{klass.inspect} relation is missing schema definition")
    end
  end

  DuplicateConfigurationError = Class.new(StandardError)
  DuplicateContainerError = Class.new(StandardError)

  InvalidOptionValueError = Class.new(StandardError)
  InvalidOptionKeyError = Class.new(StandardError)
end
