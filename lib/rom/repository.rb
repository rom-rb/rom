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
    # @param [Symbol] name
    #   the name used to track the relation
    #
    # @param [Axiom::Header] header
    #   the axiom header, or coercible to axiom header
    #
    # @example with coercible header
    #   repo = Repository::InMemory.new
    #   repo.register(:foo, [[:id, String]])
    #
    # @example with instance of axiom header
    #   repo = Repository::InMemory.new
    #   repo.register(:foo, Axiom::Header.coerce([[:id, String]]))
    #
    # @return [self]
    #
    # @api private
    def register(name, header, keys = {})
      @map[name] = build(name, Axiom::Relation::Header.coerce(header, keys))
      self
    end

    private

    # Build a axiom gateway relation
    #
    # @param [Symbol] name
    #   the relation name
    #
    # @param [Axiom::Relation::Header] header
    #
    # @return [Axiom::Adapter::Gateway]
    #
    # @api private
    #
    def build(name, header)
      adapter.gateway(Axiom::Relation::Base.new(name, header))
    end
  end # class Repository
end # module ROM
