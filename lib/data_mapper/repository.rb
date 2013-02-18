module DataMapper

  # Abstract base class for repositories
  #
  # @api private
  class Repository

    include AbstractType

    def self.coerce(name, options = EMPTY_HASH)
      if options.any?
        Persistent.new(name, adapter(options))
      else
        InMemory.new(name)
      end
    end

    # TODO make that smarter
    def self.adapter(options)
      parsed_uri = Addressable::URI.parse(options.fetch(:uri))
      Veritas::Adapter::DataObjects.new(parsed_uri)
    end

    private_class_method :adapter

    # The repository's name
    #
    # @return [Symbol]
    #
    # @api private
    attr_reader :name

    # Initialize a new instance
    #
    # @param [#to_sym] name
    #   the repository's name
    #
    # @return [undefined]
    #
    # @api private
    def initialize(name)
      @name = name
      @map  = {}
    end

    # Return the relation identified by +name+
    #
    # @example
    #   repo = Repository::InMemory.new
    #   repo.register(:foo, [[:id, String], [:foo, String]])
    #   repo.get(:foo) # => <Veritas::Relation header=Veritas::Header ...>
    #
    # @param [Symbol] name
    #   the name of the relation
    #
    # @return [Veritas::Relation]
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
    # @param [Veritas::Header] header
    #   the veritas header, or coercible to veritas header
    #
    # @example with coercible header
    #   repo = Repository::InMemory.new
    #   repo.register(:foo, [[:id, String], [:foo, String]])
    #
    # @example with instace of veritas header
    #   repo = Repository::InMemory.new
    #   repo.register(:foo, Veritas::Header.coerce([[:id, String], [:foo, String]]))
    #
    # @return [self]
    #
    # @api private
    def register(name, header)
      @map[name] = build(name, Veritas::Relation::Header.coerce(header))
      self
    end

    # A repository backed by in memory relations
    #
    # @api private
    class InMemory < self
      private

      # Build veritas in memory relation
      #
      # @param [Symbol] name
      #   the relation name
      #
      # @param [Veritas::Relation::Header] header
      #
      # @return [Veritas::Relation]
      #
      # @api private
      #
      def build(_name, header)
        Veritas::Relation.new(header, [])
      end
    end # class InMemory

    # A persistent repository backed by base relations accessible via an adapter
    #
    # @api private
    class Persistent < self

      # Initialize a new instance
      #
      # @param [#to_sym] name
      #   the repository's name
      #
      # @param [Veritas::Adapter] adapter
      #   the adapter to access relations
      #
      # @return [undefined]
      #
      # @api private
      def initialize(name, adapter)
        super(name)
        @adapter = adapter
      end

      private

      # Build veritas gateway relation
      #
      # @param [Symbol] name
      #   the relatio name
      #
      # @param [Veritas::Relation::Header] header
      #
      # @return [Veritas::Adapter::Gateway]
      #
      # @api private
      #
      def build(name, header)
        @adapter.gateway(Veritas::Relation::Base.new(name, header))
      end
    end # class Persistent
  end # class Repository
end # module DataMapper
