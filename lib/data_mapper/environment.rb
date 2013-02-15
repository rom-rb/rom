module DataMapper

  class Environment

    # The engines registered with this instance
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :engines

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

    # Initialize a new instance
    #
    # @param [Mapper::Registry, nil] registry
    #   the mapper registry to use with this instance,
    #   or a new instance in case nil was passed in.
    #
    # @return [undefined]
    #
    # @api private
    def initialize(registry = nil)
      @engines = {}
      reset(registry)
    end

    # Register a new engine to use with this instance
    #
    # @example
    #
    #   env = DataMapper::Environment.new
    #   env.setup(:default, :uri => 'postgres://localhost/test')
    #
    # @param [#to_sym] name
    #   the name to use for the engine
    #
    # @param [Addressable::Uri, String] uri
    #   the uri the adapter uses for creating a connection
    #
    # @return [self]
    #
    # @api public
    def setup(name, uri)
      engines[name.to_sym] = Engine.new(uri)
      self
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
      mapper.engine(engines[repository])
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

    # Reset this instance
    #
    # @return [undefined]
    #
    # @api private
    def reset(registry = nil)
      @mappers   = []
      @registry  = registry || Mapper::Registry.new
      @relations = Relation::Graph.new
      @finalized = false
    end

  end # class Environment

end # module DataMapper
