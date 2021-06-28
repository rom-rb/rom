# frozen_string_literal: true

require "dry/core/constants"

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
  GatewayAlreadyDefinedError = Class.new(StandardError)
  RelationAlreadyDefinedError = Class.new(StandardError)
  CommandAlreadyDefinedError = Class.new(StandardError)
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
    def initialize(key, registry = nil)
      msg =
        if registry
          "#{key.inspect} doesn't exist in #{registry.type} registry"
        else
          "#{key} doesn't exist in the registry"
        end
      super(msg)
    end
  end

  GatewayMissingError = Class.new(ElementNotFoundError)

  RelationMissingError = Class.new(ElementNotFoundError)

  MapperMissingError = Class.new(ElementNotFoundError)

  CommandNotFoundError = Class.new(ElementNotFoundError)

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
