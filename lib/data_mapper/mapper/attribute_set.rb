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
      def each
        return to_enum unless block_given?
        @attributes.each_value { |attribute| yield attribute }
        self
      end

      # @api private
      def header
        @header ||= map(&:header)
      end

      # @api private
      def load(tuple)
        each_with_object({}) do |attribute, attributes|
          attributes[attribute.name] = tuple[attribute.field]
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
