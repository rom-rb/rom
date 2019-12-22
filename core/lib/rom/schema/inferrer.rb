# frozen_string_literal: true

require 'dry/core/class_attributes'

module ROM
  class Schema
    # @api private
    class Inferrer
      extend Dry::Core::ClassAttributes
      extend Initializer

      # @!method self.attributes_inferrer
      #   @overload attributes_inferrer
      #     @return [Proc]
      #
      #   @overload attributes_inferrer(value)
      #     @param value [Proc]
      #     @return [Proc]
      #
      # @!method self.attr_class
      #   @overload attr_class
      #     @return [Class(ROM::Attribute)]
      #
      #   @overload attr_class(value)
      #     @param value [Class(ROM::Attribute)]
      #     @return [Class(ROM::Attribute)]
      defines :attributes_inferrer, :attr_class

      MissingAttributesError = Class.new(StandardError) do
        def initialize(name, attributes)
          super(
            "Following attributes in #{Relation::Name[name].relation.inspect} schema cannot "\
            "be inferred and have to be defined explicitly: #{attributes.map(&:inspect).join(', ')}"
          )
        end
      end

      DEFAULT_ATTRIBUTES = [EMPTY_ARRAY, EMPTY_ARRAY].freeze

      attributes_inferrer -> * { DEFAULT_ATTRIBUTES }

      attr_class Attribute

      include Dry::Equalizer(:options)

      # @!attribute [r] attr_class
      #   @return [Class(ROM::Attribute)]
      option :attr_class, default: -> { self.class.attr_class }

      # @!attribute [r] enabled
      #   @return [Boolean]
      option :enabled, default: -> { true }

      alias_method :enabled?, :enabled

      # @!attribute [r] attributes_inferrer
      #   @return [ROM::Schema::AttributesInferrer]
      option :attributes_inferrer, default: -> { self.class.attributes_inferrer }

      # @api private
      def call(schema, gateway)
        if enabled?
          inferred, missing = attributes_inferrer.(schema, gateway, options)
        else
          inferred, missing = DEFAULT_ATTRIBUTES
        end

        attributes = merge_attributes(schema.attributes, inferred)

        check_all_attributes_defined(schema, attributes, missing)

        { attributes: attributes }
      end

      # @api private
      def check_all_attributes_defined(schema, all_known, not_inferred)
        not_defined = not_inferred - all_known.map(&:name)

        if not_defined.size > 0
          raise MissingAttributesError.new(schema.name, not_defined)
        end
      end

      # @api private
      def merge_attributes(defined, inferred)
        type_lookup = lambda do |attrs, name|
          attrs.find { |a| a.name == name }.type
        end
        defined_with_type, defined_names =
          defined.each_with_object([[], []]) do |attr, (attrs, names)|
            attrs << if attr.type.nil?
                       attr.class.new(
                         type_lookup.(inferred, attr.name),
                         **attr.options
                       )
                     else
                       attr
                     end
            names << attr.name
          end

        defined_with_type + inferred.reject do |attr|
          defined_names.include?(attr.name)
        end
      end
    end
  end
end
