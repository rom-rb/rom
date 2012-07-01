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

      # @api public
      def field_name(attribute_name)
        self[attribute_name].field
      end

      # @api public
      def each
        return to_enum unless block_given?
        @attributes.each_value { |attribute| yield attribute }
        self
      end

      # @api private
      def header
        @header ||= select(&:primitive?).map(&:header)
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
      def add(*args)
        @attributes[args.first] = Attribute.new(*args)
        self
      end

      # @api private
      def [](name)
        @attributes[name]
      end

      # @api private
      def key
        map(&:key?)
      end

    end # class AttributeSet
  end # class Mapper
end # module DataMapper
