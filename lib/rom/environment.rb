module ROM

  # The environment used to build and finalize mappers and their relations
  #
  class Environment
    include Concord.new(:repositories)

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
