# Constants and errors common in the whole library
module ROM
  Undefined = Object.new.freeze

  AdapterLoadError = Class.new(StandardError)

  EnvAlreadyFinalizedError = Class.new(StandardError)
  RelationAlreadyDefinedError = Class.new(StandardError)
  NoRelationError = Class.new(StandardError)
  CommandError = Class.new(StandardError)
  TupleCountMismatchError = Class.new(CommandError)
  MapperMissingError = Class.new(StandardError)
  MapperMisconfiguredError = Class.new(StandardError)
  UnknownPluginError = Class.new(StandardError)
  UnsupportedRelationError = Class.new(StandardError)

  InvalidOptionValueError = Class.new(StandardError)
  InvalidOptionKeyError = Class.new(StandardError)

  class CommandFailure < StandardError
    attr_reader :command
    attr_reader :original_error

    def initialize(command, err)
      super("command: #{command.inspect}; original message: #{err.message}")
      @command = command
      @original_error = original_error
    end
  end

  EMPTY_ARRAY = [].freeze
  EMPTY_HASH = {}.freeze
end
