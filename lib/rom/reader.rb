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

    # Builds a reader instance for the provided relation
    #
    # @param [Symbol] name of the root relation
    # @param [Relation] relation that the reader will use
    # @param [MapperRegistry] registry of mappers
    # @param [Array<Symbol>] a list of method names exposed by the relation
    #
    # @return [Reader]
    #
    # @api private
    def self.build(name, relation, mappers, method_names = [])
      klass = build_class(relation, method_names)
      klass.new(name, relation, mappers)
    end

    # Build a reader subclass for the relation
    #
    # This method defines public methods on the class narrowing down data access
    # only to the methods exposed by a given relation
    #
    # @param [Relation] relation that the reader will use
    # @param [Array<Symbol>] a list of method names exposed by the relation
    #
    # @return [Class]
    #
    # @api private
    def self.build_class(relation, method_names)
      klass_name = "#{Reader.name}[#{Inflecto.camelize(relation.name)}]"

      ClassBuilder.new(name: klass_name, parent: Reader).call do |klass|
        method_names.each do |method_name|
          klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{method_name}(*args, &block)
              new_relation = relation.send(#{method_name.inspect}, *args, &block)
              self.class.new(
                new_path(#{method_name.to_s.inspect}), new_relation, mappers
              )
            end
          RUBY
        end
      end
    end

    # @api private
    def initialize(path, relation, mappers, mapper = nil)
      @path = path.to_s
      @relation = relation
      @mappers = mappers
      @mapper = mapper || mappers.by_path(@path)
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
    def with_mapper(name)
      self.class.new(path, relation, mappers, mappers.by_path(new_path(name)))
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
