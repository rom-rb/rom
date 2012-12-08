module DataMapper

  class Environment
    attr_reader :engines

    attr_reader :mappers

    attr_reader :registry

    def initialize(registry = nil)
      @engines  = {}
      @mappers  = []
      @registry = registry || Mapper::Registry.new
    end

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
    #   DataMapper.build(User, :default) do
    #     key :id
    #   end
    #
    # @param [Model, ::Class(.name, .attribute_set)] model
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
      mapper.environment(self)
      mappers << mapper
      mapper
    end

    # Finalize the environment after all mappers were defined
    #
    # @see Finalizer#run
    #
    # @example
    #
    #   DataMapper.finalize
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
