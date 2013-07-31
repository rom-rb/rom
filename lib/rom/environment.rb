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

    # Load defined schema and register relations
    #
    # @example
    #
    #   schema = Schema.build do
    #     base_relation :users do
    #       repository :test
    #
    #       attributes :id, :name, :email
    #     end
    #   end
    #
    #   env = Environment.coerce(test: 'memory://test').load_schema(schema)
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

    # Register relations in a repository
    #
    # @return [Environment]
    #
    # @api private
    def register_relations(repository_name, relations)
      relations.each do |relation|
        name           = relation.name
        repository     = repository(repository_name).register(name, relation)
        registry[name] = repository.get(name)
      end
      self
    end

  end # Environment
end # ROM
