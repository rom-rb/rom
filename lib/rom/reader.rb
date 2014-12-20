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

      names = @path.split('.')

      mapper_key = names.reverse.detect { |name| mappers.key?(name.to_sym) }
      @mapper = mappers.fetch(mapper_key.to_sym)
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
      new_relation = relation.public_send(name, *args, &block)

      splits = path.split('.')
      splits << name
      new_path = splits.join('.')

      self.class.new(new_path, new_relation, mappers)
    end
  end
end
