module ROM

  # A repository with a given +name+ and +adapter+
  #
  # @api private
  class Repository

    include Equalizer.new(:name, :adapter)

    # Coerce a given +name+ and +uri+ into a repository
    #
    # @param [Symbol] name
    #   the repository's name
    #
    # @param [Addressable::URI] uri
    #   the uri for initializing the adapter
    #
    # @return [Repository]
    #
    # @api private
    def self.coerce(name, uri)
      new(name, Axiom::Adapter.new(uri))
    end

    # The repository's name
    #
    # @return [Symbol]
    #
    # @api private
    attr_reader :name

    # The repository's adapter
    #
    # @return [Object]
    #   a axiom adapter
    #
    # @api private
    attr_reader :adapter

    # Initialize a new instance
    #
    # @param [#to_sym] name
    #   the repository's name
    #
    # @param [Object] adapter
    #   the axiom adapter to access relations
    #
    # @return [undefined]
    #
    # @api private
    def initialize(name, adapter)
      @name    = name
      @adapter = adapter
      @map     = {}
    end

    # Return the relation identified by +name+
    #
    # @example
    #
    #   repo = Repository.coerce(:test, 'in_memory://test')
    #   repo.register(:foo, [[:id, String], [:foo, String]])
    #   repo.get(:foo)
    #
    #   # => <Axiom::Relation header=Axiom::Header ...>
    #
    # @param [Symbol] name
    #   the name of the relation
    #
    # @return [Axiom::Relation]
    #
    # @raise [KeyError]
    #
    # @api private
    def get(name)
      @map.fetch(name)
    end

    # Register a relation with this repository
    #
    # @param [Axiom::Relation::Base] relation
    #
    # @return [self]
    #
    # @api private
    def register(relation)
      @map[relation.name.to_sym] = adapter.gateway(relation)
      self
    end

  end # Repository

end # ROM
