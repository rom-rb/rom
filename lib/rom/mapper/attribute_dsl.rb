require 'rom/header'
require 'rom/mapper/model_dsl'

module ROM
  class Mapper
    # Mapper attribute DSL exposed by mapper subclasses
    #
    # This class is private even though its methods are exposed by mappers.
    # Typically it's not meant to be used directly.
    #
    # @private
    class AttributeDSL
      include ModelDSL

      attr_reader :attributes, :options, :symbolize_keys, :prefix,
        :prefix_separator, :reject_keys

      # @param [Array] attributes accumulator array
      # @param [Hash] options
      #
      # @api private
      def initialize(attributes, options)
        @attributes = attributes
        @options = options
        @symbolize_keys = options.fetch(:symbolize_keys)
        @prefix = options.fetch(:prefix)
        @prefix_separator = options.fetch(:prefix_separator)
        @reject_keys = options.fetch(:reject_keys)
      end

      # Define a mapping attribute with its options
      #
      # @example
      #   dsl = AttributeDSL.new([])
      #
      #   dsl.attribute(:name)
      #   dsl.attribute(:email, from: 'user_email')
      #
      # @api public
      def attribute(name, options = EMPTY_HASH)
        with_attr_options(name, options) do |attr_options|
          add_attribute(name, attr_options)
        end
      end

      # Remove an attribute
      #
      # @example
      #   dsl = AttributeDSL.new([[:name]])
      #
      #   dsl.exclude(:name)
      #   dsl.attributes # => []
      #
      # @api public
      def exclude(*names)
        attributes.delete_if { |attr| names.include?(attr.first) }
      end

      # Define an embedded attribute
      #
      # Block exposes the attribute dsl too
      #
      # @example
      #   dsl = AttributeDSL.new([])
      #
      #   dsl.embedded :tags, type: :array do
      #     attribute :name
      #   end
      #
      #   dsl.embedded :address, type: :hash do
      #     model Address
      #     attribute :name
      #   end
      #
      # @param [Symbol] name attribute
      #
      # @param [Hash] options
      # @option options [Symbol] :type Embedded type can be :hash or :array
      # @option options [Symbol] :prefix Prefix that should be used for
      #                                  its attributes
      #
      # @api public
      def embedded(name, options, &block)
        with_attr_options(name) do |attr_options|
          mapper = options[:mapper]

          if mapper
            attributes_from_mapper(
              mapper, name, { type: :array }.update(attr_options)
            )
          else
            dsl = new(options, &block)
            attr_options.update(options)
            add_attribute(
              name, { header: dsl.header, type: :array }.update(attr_options)
            )
          end
        end
      end

      # Define an embedded hash attribute that requires "wrapping" transformation
      #
      # Typically this is used in sql context when relation is a join.
      #
      # @example
      #   dsl = AttributeDSL.new([])
      #
      #   dsl.wrap(address: [:street, :zipcode, :city])
      #
      #   dsl.wrap(:address) do
      #     model Address
      #     attribute :street
      #     attribute :zipcode
      #     attribute :city
      #   end
      #
      # @see AttributeDSL#embedded
      #
      # @api public
      def wrap(*args, &block)
        with_name_or_options(*args) do |name, options, mapper|
          wrap_options = { type: :hash, wrap: true }.update(options)

          if mapper
            attributes_from_mapper(mapper, name, wrap_options)
          else
            dsl(name, wrap_options, &block)
          end
        end
      end

      # Define an embedded hash attribute that requires "grouping" transformation
      #
      # Typically this is used in sql context when relation is a join.
      #
      # @example
      #   dsl = AttributeDSL.new([])
      #
      #   dsl.group(tags: [:name])
      #
      #   dsl.group(:tags) do
      #     model Tag
      #     attribute :name
      #   end
      #
      # @see AttributeDSL#embedded
      #
      # @api public
      def group(*args, &block)
        with_name_or_options(*args) do |name, options, mapper|
          group_options = { type: :array, group: true }.update(options)

          if mapper
            attributes_from_mapper(mapper, name, group_options)
          else
            dsl(name, group_options, &block)
          end
        end
      end

      # Define an embedded combined attribute that requires "combine" transformation
      #
      # Typically this can be used to process results of eager-loading
      #
      # @example
      #   dsl = AttributeDSL.new([])
      #
      #   dsl.combine(:tags, user_id: :id) do
      #     model Tag
      #
      #     attribute :name
      #   end
      #
      # @param [Symbol] name
      # @param [Hash] options
      #   @option options [Hash] :on The "join keys"
      #   @option options [Symbol] :type The type, either :array (default) or :hash
      #
      # @api public
      def combine(name, options, &block)
        dsl(name, {
          combine: true,
          type: options.fetch(:type, :array),
          keys: options.fetch(:on) }, &block)
      end

      # Generate a header from attribute definitions
      #
      # @return [Header]
      #
      # @api private
      def header
        Header.coerce(attributes, model: model, reject_keys: reject_keys)
      end

      private

      # Handle attribute options common for all definitions
      #
      # @api private
      def with_attr_options(name, options = EMPTY_HASH)
        attr_options = options.dup

        attr_options[:from] ||= :"#{prefix}#{prefix_separator}#{name}" if prefix

        if symbolize_keys
          attr_options.update(from: attr_options.fetch(:from) { name }.to_s)
        end

        yield(attr_options)
      end

      # Handle "name or options" syntax used by `wrap` and `group`
      #
      # @api private
      def with_name_or_options(*args)
        name, options =
          if args.size > 1
            args
          else
            [args.first, {}]
          end

        yield(name, options, options[:mapper])
      end

      # Create another instance of the dsl for nested definitions
      #
      # This is used by embedded, wrap and group
      #
      # @api private
      def dsl(name_or_attrs, options, &block)
        if block
          attributes_from_block(name_or_attrs, options, &block)
        else
          attributes_from_hash(name_or_attrs, options)
        end
      end

      # Define attributes from a nested block
      #
      # Used by embedded, wrap and group
      #
      # @api private
      def attributes_from_block(name, options, &block)
        dsl = new(options, &block)
        header = dsl.header
        add_attribute(name, options.update(header: header))
        header.each { |attr| exclude(attr.key) }
      end

      # Define attributes from the `name => attributes` hash syntax
      #
      # Used by wrap and group
      #
      # @api private
      def attributes_from_hash(hash, options)
        hash.each do |name, header|
          with_attr_options(name, options) do |attr_options|
            add_attribute(name, attr_options.update(header: header.zip))
            header.each { |attr| exclude(attr) }
          end
        end
      end

      # Infer mapper header for an embedded attribute
      #
      # @api private
      def attributes_from_mapper(mapper, name, options)
        if mapper.is_a?(Class)
          add_attribute(name, { header: mapper.header }.update(options))
        else
          raise(
            ArgumentError, ":mapper must be a class #{mapper.inspect}"
          )
        end
      end

      # Add a new attribute and make sure it overrides previous definition
      #
      # @api private
      def add_attribute(name, options)
        exclude(name, name.to_s)
        attributes << [name, options]
      end

      # Create a new dsl instance of potentially overidden options
      #
      # Embedded, wrap and group can override top-level options like `prefix`
      #
      # @api private
      def new(options, &block)
        dsl = self.class.new([], @options.merge(options))
        dsl.instance_exec(&block)
        dsl
      end
    end
  end
end
