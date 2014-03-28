# encoding: utf-8

module ROM

  # Mappers load tuples into objects and dump objects back into tuples
  #
  class Mapper
    include Equalizer.new(:header, :options)

    DEFAULT_LOADER = :load_instance_variables

    attr_reader :header, :loader, :dumper, :model, :type, :options

    # Build a mapper
    #
    # @return [Mapper]
    #
    # @api public
    def self.build(attributes, options = {})
      defaults = { type: DEFAULT_LOADER, model: OpenStruct }.update(options)

      header = Header.build(attributes)
      loader = Loader.build(header, defaults[:model], defaults[:type])

      new(header, loader, defaults)
    end

    def initialize(header, loader, options = {})
      @header = header
      @loader = loader
      @dumper = loader.inverse
      @model = options.fetch(:model)
      @type = options.fetch(:type)
      @options = options
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
      header.keys.map { |key| object.send(key.name) }
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
      header.keys.map { |key| tuple[key.name] }
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
      ary = dumper.call(object)

      ary.each_with_object([]) do |(name, value), tuple|
        attribute = header[name]

        if attribute.header
          tuple << value.values_at(*attribute.header.attribute_names)
        else
          tuple << value
        end
      end
    end

    def wrap(other)
      new(header.wrap(other))
    end

    def join(other)
      new(header.join(other.header))
    end

    def project(names)
      new(header.project(names))
    end

    def new(header)
      self.class.new(header, Loader.build(header, model, type), options)
    end

  end # Mapper

end # ROM
