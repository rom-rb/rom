# Constants and errors common in the whole library
module ROM
  Undefined = Object.new.freeze

  AdapterLoadError = Class.new(StandardError)

  EnvAlreadyFinalizedError = Class.new(StandardError)
  RelationAlreadyDefinedError = Class.new(StandardError)
  NoRelationError = Class.new(StandardError)
  NoAssociationError = Class.new(StandardError)
  CommandError = Class.new(StandardError)
  TupleCountMismatchError = Class.new(CommandError)
  MapperMissingError = Class.new(StandardError)

  InvalidOptionValueError = Class.new(StandardError)
  InvalidOptionKeyError = Class.new(StandardError)

  EMPTY_ARRAY = [].freeze
  EMPTY_HASH = {}.freeze
end
