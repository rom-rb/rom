module ROM
  # Exposes mapped tuples via enumerable interface
  #
  # See example for each method
  #
  # @api public
  class Reader
    include Enumerable
    include Equalizer.new(:path, :relation, :mapper)

    alias_method :to_ary, :to_a

    # @return [String] access path used to read a relation
    #
    # @api private
    attr_reader :path

    # @return [Relation] relation used by the reader
    #
    # @api private
    attr_reader :relation

    # @return [MapperRegistry] registry of mappers used by the reader
    #
    # @api private
    attr_reader :mappers

    # @return [Mapper] mapper to read the relation
    #
    # @api private
    attr_reader :mapper

    # @api private
    def initialize(path, relation, mappers = {})
      @path = path.to_s
      @relation = relation
      @mappers = mappers
      @mapper = mappers.by_path(@path)
    end

    # @api private
    def header
      mapper.header
    end

    # Yields tuples mapped to objects
    #
    # @example
    #
    #   # accessing root relation
    #   rom.read(:users).each { |user| # ... }
    #
    #   # accessing virtual relations
    #   rom.read(:users).adults.recent.active.each { |user| # ... }
    #
    # @api public
    def each
      mapper.process(relation) { |tuple| yield(tuple) }
    end

    # Returns a single tuple from the relation if there is one.
    #
    # @raise [ROM::TupleCountMismatchError] if the relation contains more than
    #   one tuple
    #
    # @api public
    def one
      if relation.count > 1
        raise(
          TupleCountMismatchError,
          'The relation consists of more than one tuple'
        )
      else
        mapper.process(relation).first
      end
    end

    # Like [one], but additionally raises an error if the relation is empty.
    #
    # @raise [ROM::TupleCountMismatchError] if the relation does not contain
    #   exactly one tuple
    #
    # @api public
    def one!
      one || raise(
        TupleCountMismatchError,
        'The relation does not contain any tuples'
      )
    end

    # Return a new reader with a specific mapper
    #
    # @api private
    def with(name)
      self.class.new(new_path(name), relation, mappers)
    end

    private

    # @api private
    def method_missing(name, *)
      raise(
        NoRelationError,
        "undefined relation #{name.inspect} within #{path.inspect}"
      )
    end

    # @api private
    def new_path(name)
      path.dup << ".#{name}"
    end
  end
end
