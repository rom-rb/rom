# frozen_string_literal: true

require 'dry/core/constants'

# Constants and errors common in the whole library
module ROM
  include Dry::Core::Constants

  AdapterLoadError = Class.new(StandardError)

  # Exception raised when a component is configured with an adapter that's not loaded
  class AdapterNotPresentError < StandardError
    # @api private
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
  MapperMisconfiguredError = Class.new(StandardError)
  NoRelationError = Class.new(StandardError)
  InvalidRelationName = Class.new(StandardError)
  CommandError = Class.new(StandardError)
  KeyMissing = Class.new(ROM::CommandError)
  TupleCountMismatchError = Class.new(CommandError)
  UnknownPluginError = Class.new(StandardError)
  UnsupportedRelationError = Class.new(StandardError)
  MissingAdapterIdentifierError = Class.new(StandardError)
  AttributeAlreadyDefinedError = Class.new(StandardError)

  # Exception raised when a reserved keyword is used as a relation name
  class InvalidRelationName < StandardError
    # @api private
    def initialize(relation)
      super("Relation name: #{relation} is a protected word, please use another relation name")
    end
  end

  # Exception raised when an element inside a component registry is not found
  class ElementNotFoundError < KeyError
    # @api private
    def initialize(key, registry)
      super(set_message(key, registry))
    end

    # @api private
    def set_message(key, registry)
      "#{key.inspect} doesn't exist in #{registry.class.name} registry"
    end
  end

  MapperMissingError = Class.new(ElementNotFoundError)

  CommandNotFoundError = Class.new(ElementNotFoundError) do
    # @api private
    def set_message(key, registry)
      "There is no :#{key} command for :#{registry.relation_name} relation"
    end
  end

  MissingSchemaClassError = Class.new(StandardError) do
    # @api private
    def initialize(klass)
      super("#{klass.inspect} relation is missing schema_class")
    end
  end

  MissingSchemaError = Class.new(StandardError) do
    # @api private
    def initialize(klass)
      super("#{klass.inspect} relation is missing schema definition")
    end
  end

  DuplicateConfigurationError = Class.new(StandardError)
  DuplicateContainerError = Class.new(StandardError)

  InvalidOptionValueError = Class.new(StandardError)
  InvalidOptionKeyError = Class.new(StandardError)
end
