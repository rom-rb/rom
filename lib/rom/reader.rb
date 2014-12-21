module ROM
  # Exposes mapped tuples via enumerable interface
  #
  # See example for each method
  #
  # @api public
  class Reader
    include Enumerable
    include Equalizer.new(:path, :relation, :mapper)

    attr_reader :path, :relation, :header, :mappers, :mapper

    # @api private
    def initialize(path, relation, mappers = {})
      @path = path.to_s
      @relation = relation
      @mappers = mappers
      @mapper = mappers.by_path(@path)
      @header = mapper.header
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

    # @api private
    def respond_to_missing?(name, _include_private = false)
      relation.respond_to?(name)
    end

    private

    # @api private
    def method_missing(name, *args, &block)
      if relation.respond_to?(name)
        new_relation = relation.public_send(name, *args, &block)
        self.class.new(new_path(name), new_relation, mappers)
      else
        raise(
          NoRelationError,
          "undefined relation #{name.inspect} within #{path.inspect}"
        )
      end
    end

    # @api private
    def new_path(name)
      path.dup << ".#{name}"
    end
  end
end
