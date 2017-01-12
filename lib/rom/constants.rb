# Constants and errors common in the whole library
module ROM
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
  NoRelationError = Class.new(StandardError)
  CommandError = Class.new(StandardError)
  KeyMissing = Class.new(ROM::CommandError)
  TupleCountMismatchError = Class.new(CommandError)
  MapperMissingError = Class.new(StandardError)
  UnknownPluginError = Class.new(StandardError)
  UnsupportedRelationError = Class.new(StandardError)
  MissingAdapterIdentifierError = Class.new(StandardError)

  MissingSchemaClassError = Class.new(StandardError) do
    def initialize(klass)
      super("#{klass.inspect} relation is missing schema_class")
    end
  end

  DuplicateConfigurationError = Class.new(StandardError)
  DuplicateContainerError = Class.new(StandardError)

  InvalidOptionValueError = Class.new(StandardError)
  InvalidOptionKeyError = Class.new(StandardError)
end
