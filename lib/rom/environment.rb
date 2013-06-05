module ROM

  # The environment used to build and finalize mappers and their relations
  #
  class Environment
    include Equalizer.new(:repositories, :relations)

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

      new(config.each_with_object({}) { |(name, uri), hash|
        hash[name.to_sym] = Repository.coerce(name, Addressable::URI.parse(uri))
      })
    end

    # The relations registered with this environment
    #
    # @return [Relation::Graph]
    #
    # @api private
    attr_reader :relations

    # The repositories setup with this environment
    #
    # @return [Hash<Symbol, Repository>]
    #
    # @api private
    attr_reader :repositories

    protected :repositories

    # Initialize a new instance
    #
    # @param [Hash<Symbol, Repository>] repositories
    #   the repository configuration for this environment
    #
    # @return [undefined]
    #
    # @api private
    def initialize(repositories)
      @repositories = repositories
      @relations    = Graph.new
    end

    # The repository with the given +name+
    #
    # @return [Repository]
    #
    # @api private
    def repository(name)
      repositories[name]
    end

    # Finalize the environment after all mappers were defined
    #
    # @return [self]
    #
    # @api public
    def finalize
      return self if @finalized
      @finalized = true
      self
    end

  end # class Environment
end # module ROM
