module ROM

  # The environment used to build and finalize mappers and their relations
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
    #   an environment or a hash of adapter uri strings, keyed by repository name
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
    # @api public
    def self.build(repositories, registry = {})
      new(repositories, registry)
    end

    # Return registered rom's relation
    #
    # @param [Symbol] relation name
    #
    # @return [Relation]
    #
    # @api public
    def [](name)
      registry[name]
    end

    # Load defined rom schema and register relations
    #
    # @param [Schema] schema
    #
    # @return [Environment]
    #
    # @api public
    def load_schema(schema)
      schema.each do |repository_name, relations|
        register_relations(repository_name, relations)
      end

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

    private

    # @api private
    def register_relations(repository_name, relations)
      relations.each do |relation|
        name           = relation.name
        registry[name] = repository(repository_name).register(name, relation).get(name)
      end
    end

  end # Environment
end # ROM
