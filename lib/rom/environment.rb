# encoding: utf-8

require 'rom/environment/builder'

module ROM

  # The environment configures repositories and loads schema with relations
  #
  class Environment
    # @api private
    attr_reader :repositories, :relations

    # Return schema registry
    #
    # @return [Schema]
    #
    # @api public
    attr_reader :schema

    # Return mapper registry
    #
    # @return [Hash]
    #
    # @api public
    attr_reader :mappers

    # @api private
    def initialize(repositories, schema, relations, mappers)
      @repositories = repositories
      @schema = schema
      @relations = relations
      @mappers = mappers
    end

    # Setup ROM environment
    #
    # @example
    #
    #   env = ROM::Environment.setup(test: 'memory://test') do
    #     schema do
    #       base_relation(:users) do
    #         repository :test
    #
    #         attribute :id, Integer
    #         attribute :name, String
    #
    #         key :id
    #       end
    #     end
    #
    #     mapping do
    #       relation(:users) do
    #         model User
    #
    #         map :id, :name
    #       end
    #     end
    #
    #   end
    #
    # @param [Environment, Hash<#to_sym, String>] config
    #   an environment or a hash of adapter uri strings,
    #   keyed by repository name
    #
    # @return [Environment::Builder]
    #
    # @api public
    def self.setup(config, &block)
      builder = Builder.call(config)

      if block
        builder.instance_eval(&block)
        builder.finalize
      else
        builder
      end
    end

    # Return registered relation
    #
    # @example
    #
    #   env[:users]
    #
    # @param [Symbol] relation name
    #
    # @return [Relation]
    #
    # @api public
    def [](name)
      relations[name]
    end

    # The repository with the given +name+
    #
    # @return [Repository]
    #
    # @api public
    def repository(name)
      repositories[name]
    end

  end # Environment

end # ROM
