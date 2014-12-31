module ROM
  # Exposes mapped tuples via enumerable interface
  #
  # See example for each method
  #
  # @api public
  class Reader
    MapperMissingError = Class.new(StandardError)

    include Enumerable
    include Equalizer.new(:path, :relation, :mapper)

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

    # Build a reader subclass for the relation and instantiate it
    #
    # This method defines public methods on the class narrowing down data access
    # only to the methods exposed by a given relation
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
      klass = Class.new(self)

      klass_name = "#{self.name}[#{Inflecto.camelize(relation.name)}]"

      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.name
          #{klass_name.inspect}
        end

        def self.inspect
          name
        end

        def self.to_s
          name
        end
      RUBY

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

      klass.new(name, relation, mappers)
    end

    # @api private
    def initialize(path, relation, mappers = {})
      @path = path.to_s
      @relation = relation
      @mappers = mappers
      @mapper = mappers.by_path(@path) || raise(MapperMissingError, path)
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

    private

    # @api private
    def method_missing(name)
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
