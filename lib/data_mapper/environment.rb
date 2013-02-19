module DataMapper

  class Environment

    def self.coerce(config)
      return config if config.kind_of?(self)

      new(config.each_with_object({}) { |(name, uri), hash|
        hash[name.to_sym] = Repository.coerce(name, Addressable::URI.parse(uri))
      })
    end

    # The mappers built with this instance
    #
    # @return [Array<Mapper>]
    #
    # @api private
    attr_reader :mappers

    # The mapper registry used by this instance
    #
    # @return [Mapper::Registry]
    #
    # @api private
    attr_reader :registry

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
    # @param [Hash<Symbol, Addressable::URI>] repositories
    #   the repository configuration for this environment
    #
    # @return [undefined]
    #
    # @api private
    def initialize(repositories)
      @repositories = repositories
      @mappers      = []
      @registry     = Mapper::Registry.new
      @relations    = Relation::Graph.new
      @finalized    = false
    end

    # The repository with the given +name+
    #
    # @return [Repository]
    #
    # @api private
    def repository(name)
      repositories[name]
    end

    # Return the mapper instance for the given model class
    #
    # @example
    #
    #   class User
    #     include DataMapper::Model
    #
    #     attribute :id,   Integer
    #     attribute :name, String
    #   end
    #
    #   env = DataMapper::Environment.new
    #   env.setup(:default, :uri => 'postgres://localhost/test')
    #   env.build(User, :default)
    #   env[User] # => the user mapper
    #
    # @param [Class] model
    #   a domain model class
    #
    # @return [Mapper]
    #
    # @api public
    def [](model)
      registry[model]
    end

    # Generates mappers class
    #
    # @see Mapper::Builder::Class.create
    #
    # @example
    #
    #   class User
    #     include DataMapper::Model
    #
    #     attribute :id,   Integer
    #     attribute :name, String
    #   end
    #
    #   env = DataMapper::Environment.new
    #   env.setup(:default, :uri => 'postgres://localhost/test')
    #   env.build(User, :default) do
    #     key :id
    #   end
    #
    # @param [Model, Class(.name, .attribute_set)] model
    #   the model used by the generated mapper
    #
    # @param [Symbol] repository
    #   the repository name to use for the generated mapper
    #
    # @param [Proc, nil] &block
    #   a block to be class_eval'ed in the context of the generated mapper
    #
    # @return [Relation::Mapper]
    #
    # @api public
    def build(model, repository, &block)
      mapper = Mapper::Builder.create(model, repository, &block)
      mappers << mapper
      mapper
    end

    # Finalize the environment after all mappers were defined
    #
    # @see Finalizer.call
    #
    # @example
    #
    #   class User
    #     include DataMapper::Model
    #
    #     attribute :id,   Integer
    #     attribute :name, String
    #   end
    #
    #   env = DataMapper::Environment.new
    #   env.setup(:default, :uri => 'postgres://localhost/test')
    #   env.build(User, :default) do
    #     key :id
    #   end
    #   env.finalize
    #
    # @return [self]
    #
    # @api public
    def finalize
      return self if @finalized
      Finalizer.call(self)
      @finalized = true
      self
    end

  end # class Environment
end # module DataMapper
