module ROM

  # Mappers load tuples into objects and dump objects back into tuples
  #
  class Mapper
    include Concord::Public.new(:header, :loader, :dumper)

    DEFAULT_LOADER = Loader::Allocator
    DEFAULT_DUMPER = Dumper

    # Build a mapper
    #
    # @example
    #
    #   header = Mapper::Header.build([[:user_name, String]], map: { user_name: :name })
    #
    #   mapper = Mapper.build(header, User)
    #   mapper = Mapper.build(header, User, loader_class: Loader::ObjectBuilder)
    #
    # @param [Header]
    # @param [Class]
    # @param [Hash]
    #
    # @return [Mapper]
    #
    # @api public
    def self.build(header, model, options = {})
      loader_class = options.fetch(:loader_class) { DEFAULT_LOADER }
      dumper_class = options.fetch(:dumper_class) { DEFAULT_DUMPER }

      loader = loader_class.new(header, model)
      dumper = dumper_class.new(header, model)

      new(header, loader, dumper)
    end

    # Project and rename given relation
    #
    # @example
    #
    #   mapper.call(relation)
    #
    # @param [Axiom::Relation]
    #
    # @return [Axiom::Relation]
    #
    # @api public
    def call(relation)
      mapping    = header.mapping
      attributes = mapping.keys

      relation.project(attributes).rename(mapping)
    end

    # Retrieve identity from the given object
    #
    # @example
    #
    #   mapper.identity(user) # => [1]
    #
    # @param [Object]
    #
    # @return [Array]
    #
    # @api public
    def identity(object)
      dumper.identity(object)
    end

    # Return identity from the given tuple
    #
    # @example
    #
    #   mapper.identity_from_tuple({id: 1}) # => [1]
    #
    # @param [Axiom::Tuple,Hash]
    #
    # @return [Array]
    #
    # @api public
    def identity_from_tuple(tuple)
      loader.identity(tuple)
    end

    # Build a new model instance
    #
    # @example
    #
    #   mapper = Mapper.build(header, User)
    #   mapper.new_object(id: 1, name: 'Jane') # => #<User @id=1 @name="Jane">
    #
    # @api public
    def new_object(*args, &block)
      dumper.new_object(*args, &block)
    end

    # Load an object instance from the tuple
    #
    # @api private
    def load(tuple)
      loader.call(tuple)
    end

    # Dump an object into a tuple
    #
    # @api private
    def dump(object)
      dumper.call(object)
    end

  end # Mapper

end # ROM
