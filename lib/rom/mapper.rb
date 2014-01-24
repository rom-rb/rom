# encoding: utf-8

module ROM

  # Mappers load tuples into objects and dump objects back into tuples
  #
  class Mapper
    include Concord::Public.new(:header, :loader, :dumper)

    LOADERS = {
      allocator:        Loader::Allocator,
      object_builder:   Loader::ObjectBuilder,
      attribute_writer: Loader::AttributeWriter
    }

    DUMPERS = {
      default: Dumper
    }

    DEFAULT_LOADER = :allocator
    DEFAULT_DUMPER = :default

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
      loader_class = LOADERS[options.fetch(:loader, DEFAULT_LOADER)]
      dumper_class = DUMPERS[options.fetch(:dumper, DEFAULT_DUMPER)]

      header = Header.build(header, options)
      loader = loader_class.new(header, model)
      dumper = dumper_class.new(header)

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
      model.new(*args, &block)
    end

    # Return model used by this mapper
    #
    # @return [Class]
    #
    # @api public
    def model
      loader.model
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
