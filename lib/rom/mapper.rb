# encoding: utf-8

require 'ostruct'

require 'rom/constants'
require 'rom/mapper/header'
require 'rom/mapper/loader_builder'

module ROM

  # Mappers load tuples into objects and dump objects back into tuples
  #
  class Mapper
    include Equalizer.new(:header, :options)

    DEFAULT_LOADER = :load_instance_variables

    attr_reader :header, :loader, :dumper, :model, :type, :options

    # Build a mapper
    #
    # @example
    #
    #   User = Class.new { attr_reader :id, :name }
    #
    #   mapper = ROM::Mapper.build([[:id, from: :user_id], [:name, from: :user_name]], model: User)
    #
    #   user = mapper.load(user_id: 1, user_name: 'Jane')
    #   # => #<User:0x007fee3b8bf2c8 @id=1, @name="Jane">
    #
    #   tuple = mapper.dump(user)
    #   # => [1, "Jane"]
    #
    # @return [Mapper]
    #
    # @api public
    def self.build(*args, &block)
      if block
        definition = Builder::Definition.new(&block)
        build(definition.attributes, definition.options)
      else
        attributes = args.first
        options = args[1] || EMPTY_HASH

        defaults = { type: DEFAULT_LOADER, model: OpenStruct }.update(options)

        header = Header.build(attributes)
        loader = LoaderBuilder.call(header, defaults[:model], defaults[:type])

        new(header, loader, defaults)
      end
    end

    # @api private
    def initialize(header, loader, options)
      @header = header
      @loader = loader
      @dumper = loader.inverse
      @model = options.fetch(:model)
      @type = options.fetch(:type)
      @options = options
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
    # @api public
    def load(tuple)
      loader.call(tuple)
    end

    # Dump an object into a tuple
    #
    # @api public
    #
    # TODO: it's not clear how a tuple should look like for grouped/wrapped
    #       relation. the current implementation is temporary
    def dump(object)
      ary = dumper.call(object)

      ary.each_with_object([]) do |(name, value), tuple|
        attribute = header.detect { |attr| attr.tuple_key == name }

        if attribute.respond_to?(:header)
          names = attribute.header.attribute_names

          if value.is_a?(Hash)
            tuple << value.values_at(*names)
          elsif value.is_a?(Array)
            tuple << value.map { |v| v.values_at(*names) }
          else
            raise NotImplementedError
          end
        else
          tuple << value
        end
      end
    end

    # TODO: this should map the wrapping hash into {Symbol => Mapper::Header}
    #       otherwise header is coupled to mapper
    #
    # @api public
    def wrap(other)
      new(header.wrap(other))
    end

    # TODO: this should map the grouping hash into {Symbol => Mapper::Header}
    #       otherwise header is coupled to mapper
    #
    # @api public
    def group(other)
      new(header.group(other))
    end

    # @api public
    def join(other)
      new(header.join(other.header))
    end

    # @api public
    def project(names)
      new(header.project(names))
    end

    # @api public
    def rename(names)
      new(header.rename(names))
    end

    # @api private
    def attribute(type, name)
      type.build(name, type: model, header: header, node: loader.node)
    end

    # @api private
    def new(new_header)
      self.class.build(new_header, options)
    end

  end # Mapper

end # ROM
