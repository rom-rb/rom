require 'dry/core/class_attributes'

module ROM
  class Schema
    # @api private
    class Inferrer
      extend Dry::Core::ClassAttributes
      extend Initializer

      defines :attributes_inferrer, :attr_class

      MissingAttributesError = Class.new(StandardError) do
        def initialize(name, attributes)
          super("missing attributes in #{name.inspect} schema: #{attributes.map(&:inspect).join(', ')}")
        end
      end

      DEFAULT_ATTRIBUTES = [EMPTY_ARRAY, EMPTY_ARRAY].freeze

      attributes_inferrer -> * { DEFAULT_ATTRIBUTES }

      attr_class Attribute

      include Dry::Equalizer(:options)

      option :attr_class, default: -> { self.class.attr_class }

      option :enabled, default: -> { true }

      alias_method :enabled?, :enabled

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
        defined_names = defined.map(&:name)

        defined + inferred.reject { |attr| defined_names.include?(attr.name) }
      end

      # @api private
      def with(new_options)
        self.class.new(options.merge(new_options))
      end
    end
  end
end
