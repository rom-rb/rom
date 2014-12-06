require 'concord'
require 'charlatan'
require 'inflecto'

require 'rom/version'
require 'rom/support/registry'

require 'rom/header'
require 'rom/relation'
require 'rom/mapper'
require 'rom/reader'

require 'rom/commands'

require 'rom/adapter'
require 'rom/repository'
require 'rom/env'

require 'rom/boot'

module ROM
  EnvAlreadyFinalizedError = Class.new(StandardError)
  CommandError = Class.new(StandardError)
  TupleCountMismatchError = Class.new(CommandError)

  InvalidOptionError = Class.new(StandardError) do
    def initialize(option, valid_values)
      super("#{option} should be one of #{valid_values.inspect}")
    end
  end

  Schema = Class.new(Registry)
  RelationRegistry = Class.new(Registry)
  ReaderRegistry = Class.new(Registry)

  # Starts the setup process for schema, relations and mappers
  #
  # @param [Hash] options repository URIs
  #
  # @return [Boot] boot object
  #
  # @api public
  def self.setup(options, &block)
    adapters = options.each_with_object({}) do |(name, uri), hash|
      hash[name] = Adapter.setup(uri)
    end

    repositories = adapters.each_with_object({}) do |(name, adapter), hash|
      hash[name] = Repository.new(adapter)
    end

    boot = Boot.new(repositories)

    if block
      boot.instance_exec(&block)
      boot.finalize
    else
      boot
    end
  end

end
