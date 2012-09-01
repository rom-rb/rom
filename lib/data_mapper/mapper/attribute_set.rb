module DataMapper
  class Mapper

    # AttributeSet
    #
    # @api private
    class AttributeSet
      include Enumerable

      # @api private
      def initialize
        @attributes = {}
      end

      # @api public
      def finalize
        each { |attribute| attribute.finalize }
      end

      # @api private
      def add(*args)
        @attributes[args.first] = Attribute.build(*args)
        self
      end

      # @api public
      def each
        return to_enum unless block_given?
        @attributes.each_value { |attribute| yield attribute }
        self
      end

      # @api public
      def field_name(attribute_name)
        self[attribute_name].field
      end

      # @api private
      def header
        @header ||= primitives.map(&:header)
      end

      # @api private
      def primitives
        @primitives ||= select { |attribute|
          attribute.kind_of?(Attribute::Primitive)
        }
      end

      # @api private
      def fields
        header.map(&:first)
      end

      # @api private
      def load(tuple)
        each_with_object({}) do |attribute, attributes|
          attributes[attribute.name] = attribute.load(tuple)
        end
      end

      # @api private
      def [](name)
        @attributes[name]
      end

      # @api private
      def key
        select(&:key?)
      end

    end # class AttributeSet
  end # class Mapper
end # module DataMapper
