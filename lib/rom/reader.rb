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

    attr_reader :path, :relation, :mappers, :mapper

    def self.build(name, relation, mappers, method_names = [])
      klass = Class.new(self)

      klass_name =
        if relation.respond_to?(:name)
          "#{self.name}[#{Inflecto.camelize(relation.name)}]"
        else
          self.name
        end

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
