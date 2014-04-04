# encoding: utf-8

module ROM

  # The environment configures repositories and loads schema with relations
  #
  class Environment
    include Equalizer.new(:relations)

    attr_reader :repositories, :schema, :relations, :mappers

    def initialize(repositories, schema, relations, mappers)
      @repositories = repositories
      @schema = schema
      @relations = relations
      @mappers = mappers
    end

    # Build an environment instance from a repository config hash
    #
    # @example
    #
    #   config = { 'test' => 'memory://test' }
    #   env    = ROM::Environment.setup(config)
    #
    # @param [Environment, Hash<#to_sym, String>] config
    #   an environment or a hash of adapter uri strings,
    #   keyed by repository name
    #
    # @return [Environment]
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
