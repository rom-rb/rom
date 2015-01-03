require 'concord'
require 'charlatan'
require 'inflecto'

require 'rom/version'
require 'rom/support/registry'

require 'rom/header'
require 'rom/relation'
require 'rom/mapper'
require 'rom/reader'

require 'rom/processor/transproc'

require 'rom/commands'

require 'rom/adapter'
require 'rom/repository'

require 'rom/config'
require 'rom/env'

require 'rom/global'
require 'rom/setup'

module ROM
  EnvAlreadyFinalizedError = Class.new(StandardError)
  CommandError = Class.new(StandardError)
  TupleCountMismatchError = Class.new(CommandError)
  NoRelationError = Class.new(StandardError)
  MapperMissingError = Class.new(StandardError)

  InvalidOptionError = Class.new(StandardError) do
    def initialize(option, valid_values)
      super("#{option} should be one of #{valid_values.inspect}")
    end
  end

  Schema = Class.new(Registry)
  RelationRegistry = Class.new(Registry)
  ReaderRegistry = Class.new(Registry)

  EMPTY_HASH = {}.freeze

  extend Global
end
