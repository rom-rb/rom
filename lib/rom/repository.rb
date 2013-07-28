module ROM

  # A repository with a given +name+ and +adapter+
  #
  # @api private
  class Repository
    include Concord.new(:name, :adapter, :relations)

    # Build a repository with a given +name+ and +uri+
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
    def self.build(name, uri, relations = {})
      new(name, Axiom::Adapter.build(uri), relations)
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
    # @api public
    def get(name)
      relations.fetch(name)
    end

    # Register a relation with this repository
    #
    # @param [Axiom::Relation::Base] relation
    #
    # @return [self]
    #
    # @api private
    def register(name, relation)
      adapter[name]   = relation
      relations[name] = adapter[name]
      self
    end

  end # Repository

end # ROM
