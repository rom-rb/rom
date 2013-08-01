# encoding: utf-8

module ROM

  # The environment configures repositories and loads schema with relations
  #
  class Environment
    include Concord.new(:repositories, :registry)

    # Coerce a repository config hash into an environment instance
    #
    # @example
    #
    #   config = { 'test' => 'in_memory://test' }
    #   env    = ROM::Environment.coerce(config)
    #
    # @param [Environment, Hash<#to_sym, String>] config
    #   an environment or a hash of adapter uri strings,
    #   keyed by repository name
    #
    # @return [Environment]
    #
    # @api public
    def self.coerce(config)
      return config if config.kind_of?(self)

      repositories = config.each_with_object({}) { |(name, uri), hash|
        hash[name.to_sym] = Repository.build(name, Addressable::URI.parse(uri))
      }

      build(repositories)
    end

    # Build a new environment
    #
    # @param [Hash] repositories
    #
    # @param [Hash] registry for relations
    #
    # @return [Environment]
    #
    # @api private
    def self.build(repositories, registry = {})
      new(repositories, registry)
    end

    # Build a relation schema for this environment
    #
    # @example
    #   env = Environment.coerce(test: 'memory://test')
    #
    #   env.schema do
    #     base_relation :users do
    #       repository :test
    #
    #       attribute :id, Integer
    #       attribute :name, String
    #     end
    #   end
    #
    # @return [Schema]
    #
    # @api public
    def schema(&block)
      if block_given?
        @schema = Schema.build(repositories, &block)
      end
      @schema
    end

    # @api public
    def mapping(&block)
      Mapping.build(self, &block)
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
      registry[name]
    end

    # Register a rom relation
    #
    # @return [Environment]
    #
    # @api private
    def register(name, relation)
      registry[name] = relation
      self
    end

    # The repository with the given +name+
    #
    # @return [Repository]
    #
    # @api private
    def repository(name)
      repositories[name]
    end

  end # Environment
end # ROM
