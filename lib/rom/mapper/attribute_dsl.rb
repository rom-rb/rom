# frozen_string_literal: true

require "rom/header"
require "rom/mapper/model_dsl"

module ROM
  class Mapper
    # Mapper attribute DSL exposed by mapper subclasses
    #
    # This class is private even though its methods are exposed by mappers.
    # Typically it's not meant to be used directly.
    #
    # TODO: break this madness down into smaller pieces
    #
    # @api private
    class AttributeDSL
      include ModelDSL

      attr_reader :attributes, :options, :copy_keys, :symbolize_keys, :reject_keys, :steps

      # @param [Array] attributes accumulator array
      # @param [Hash] options
      #
      # @api private
      def initialize(attributes, options)
        @attributes = attributes
        @options = options
        @copy_keys = options.fetch(:copy_keys)
        @symbolize_keys = options.fetch(:symbolize_keys)
        @prefix = options.fetch(:prefix)
        @prefix_separator = options.fetch(:prefix_separator)
        @reject_keys = options.fetch(:reject_keys)
        @steps = []
      end

      # Redefine the prefix for the following attributes
      #
      # @example
      #
      #   dsl = AttributeDSL.new([])
      #   dsl.attribute(:prefix, 'user')
      #
      # @api public
      def prefix(value = Undefined)
        if value.equal?(Undefined)
          @prefix
        else
          @prefix = value
        end
      end

      # Redefine the prefix separator for the following attributes
      #
      # @example
      #
      #   dsl = AttributeDSL.new([])
      #   dsl.attribute(:prefix_separator, '.')
      #
      # @api public
      def prefix_separator(value = Undefined)
        if value.equal?(Undefined)
          @prefix_separator
        else
          @prefix_separator = value
        end
      end

      # Define a mapping attribute with its options and/or block
      #
      # @example
      #   dsl = AttributeDSL.new([])
      #
      #   dsl.attribute(:name)
      #   dsl.attribute(:email, from: 'user_email')
      #   dsl.attribute(:name) { 'John' }
      #   dsl.attribute(:name) { |t| t.upcase }
      #
      # @api public
      def attribute(name, options = EMPTY_HASH, &block)
        with_attr_options(name, options) do |attr_options|
          if options[:type] && block
            raise ArgumentError,
                  "can't specify type and block at the same time"
          end
          attr_options[:coercer] = block if block
          add_attribute(name, attr_options)
        end
      end

      def exclude(name)
        attributes << [name, {exclude: true}]
      end

      # Perform transformations sequentially
      #
      # @example
      #   dsl = AttributeDSL.new()
      #
      #   dsl.step do
      #     attribute :name
      #   end
      #
      # @api public
      def step(options = EMPTY_HASH, &block)
        steps << new(options, &block)
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
            embedded_options = {type: :array}.update(options)
            attributes_from_mapper(
              mapper, name, embedded_options.update(attr_options)
            )
          else
            dsl = new(options, &block)
            attr_options.update(options)
            add_attribute(
              name, {header: dsl.header, type: :array}.update(attr_options)
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
        ensure_mapper_configuration("wrap", args, block_given?)

        with_name_or_options(*args) do |name, options, mapper|
          wrap_options = {type: :hash, wrap: true}.update(options)

          if mapper
            attributes_from_mapper(mapper, name, wrap_options)
          else
            dsl(name, wrap_options, &block)
          end
        end
      end

      # Define an embedded hash attribute that requires "unwrapping" transformation
      #
      # Typically this is used in no-sql context to normalize data before
      # inserting to sql gateway.
      #
      # @example
      #   dsl = AttributeDSL.new([])
      #
      #   dsl.unwrap(address: [:street, :zipcode, :city])
      #
      #   dsl.unwrap(:address) do
      #     attribute :street
      #     attribute :zipcode
      #     attribute :city
      #   end
      #
      # @see AttributeDSL#embedded
      #
      # @api public
      def unwrap(*args, &block)
        with_name_or_options(*args) do |name, options, mapper|
          unwrap_options = {type: :hash, unwrap: true}.update(options)

          if mapper
            attributes_from_mapper(mapper, name, unwrap_options)
          else
            dsl(name, unwrap_options, &block)
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
        ensure_mapper_configuration("group", args, block_given?)

        with_name_or_options(*args) do |name, options, mapper|
          group_options = {type: :array, group: true}.update(options)

          if mapper
            attributes_from_mapper(mapper, name, group_options)
          else
            dsl(name, group_options, &block)
          end
        end
      end

      # Define an embedded array attribute that requires "ungrouping" transformation
      #
      # Typically this is used in non-sql context being prepared for import to sql.
      #
      # @example
      #   dsl = AttributeDSL.new([])
      #   dsl.ungroup(tags: [:name])
      #
      # @see AttributeDSL#embedded
      #
      # @api public
      def ungroup(*args, &block)
        with_name_or_options(*args) do |name, options, *|
          ungroup_options = {type: :array, ungroup: true}.update(options)
          dsl(name, ungroup_options, &block)
        end
      end

      # Define an embedded hash attribute that requires "fold" transformation
      #
      # Typically this is used in sql context to fold single joined field
      # to the array of values.
      #
      # @example
      #   dsl = AttributeDSL.new([])
      #
      #   dsl.fold(tags: [:name])
      #
      # @see AttributeDSL#embedded
      #
      # @api public
      def fold(*args, &block)
        with_name_or_options(*args) do |name, *|
          fold_options = {type: :array, fold: true}
          dsl(name, fold_options, &block)
        end
      end

      # Define an embedded hash attribute that requires "unfold" transformation
      #
      # Typically this is used in non-sql context to convert array of
      # values (like in Cassandra 'SET' or 'LIST' types) to array of tuples.
      #
      # Source values are assigned to the first key, the other keys being left blank.
      #
      # @example
      #   dsl = AttributeDSL.new([])
      #
      #   dsl.unfold(tags: [:name, :type], from: :tags_list)
      #
      #   dsl.unfold :tags, from: :tags_list do
      #     attribute :name, from: :tag_name
      #     attribute :type, from: :tag_type
      #   end
      #
      # @see AttributeDSL#embedded
      #
      # @api public
      def unfold(name, options = EMPTY_HASH)
        with_attr_options(name, options) do |attr_options|
          old_name = attr_options.fetch(:from, name)
          dsl(old_name, type: :array, unfold: true) do
            attribute name, attr_options
            yield if block_given?
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
        dsl = new(options, &block)

        attr_opts = {
          type: options.fetch(:type, :array),
          keys: options.fetch(:on),
          combine: true,
          header: dsl.header
        }

        add_attribute(name, attr_opts)
      end

      # Generate a header from attribute definitions
      #
      # @return [Header]
      #
      # @api private
      def header
        Header.coerce(attributes, copy_keys: copy_keys, model: model, reject_keys: reject_keys)
      end

      private

      # Remove the attribute used somewhere else (in wrap, group, model etc.)
      #
      # @api private
      def remove(*names)
        attributes.delete_if { |attr| names.include?(attr.first) }
      end

      # Handle attribute options common for all definitions
      #
      # @api private
      def with_attr_options(name, options = EMPTY_HASH)
        attr_options = options.dup

        if @prefix
          attr_options[:from] ||= "#{@prefix}#{@prefix_separator}#{name}"
          attr_options[:from] = attr_options[:from].to_sym if name.is_a? Symbol
        end

        attr_options.update(from: attr_options.fetch(:from) { name }.to_s) if symbolize_keys

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
        header.each { |attr| remove(attr.key) unless name == attr.key }
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
            header.each { |attr| remove(attr) unless name == attr }
          end
        end
      end

      # Infer mapper header for an embedded attribute
      #
      # @api private
      def attributes_from_mapper(mapper, name, options)
        if mapper.is_a?(Class)
          add_attribute(name, {header: mapper.header}.update(options))
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
        remove(name, name.to_s)
        attributes << [name, options]
      end

      # Create a new dsl instance of potentially overidden options
      #
      # Embedded, wrap and group can override top-level options like `prefix`
      #
      # @api private
      def new(options, &block)
        dsl = self.class.new([], @options.merge(options))
        dsl.instance_exec(&block) unless block.nil?
        dsl
      end

      # Ensure the mapping configuration isn't ambiguous
      #
      # @api private
      def ensure_mapper_configuration(method_name, args, block_present)
        if args.first.is_a?(Hash) && block_present
          raise MapperMisconfiguredError,
                "Cannot configure `#{method_name}#` using both options and a block"
        end
        if args.first.is_a?(Hash) && args.first[:mapper]
          raise MapperMisconfiguredError,
                "Cannot configure `#{method_name}#` using both options and a mapper"
        end
      end
    end
  end
end
