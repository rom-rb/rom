# encoding: utf-8

module ROM

  # Mappers load tuples into objects and dump objects back into tuples
  #
  class Mapper
    include Concord::Public.new(:header, :loader, :dumper)

    DEFAULT_LOADER = :load_instance_variables

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
      loader_node_name = options.fetch(:loader, DEFAULT_LOADER)

      header = Header.build(header, options)
      loader = Loader.build(header, model, loader_node_name)
      dumper = Dumper.build(header, loader.transformer.inverse)

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
