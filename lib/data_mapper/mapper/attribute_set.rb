module DataMapper
  class Mapper

    # AttributeSet
    #
    # @api private
    class AttributeSet

      # @api private
      def initialize
        @attributes = {}
      end

      # @api private
      def header
        @header ||= @attributes.values.map do |attribute|
          [ attribute.field, attribute.type ]
        end
      end

      # @api private
      def map(tuple)
        @attributes.values.each_with_object({}) do |attribute, attributes|
          attributes[attribute.name] = tuple[attribute.field]
        end
      end

      # @api private
      def add(*args)
        @attributes[args[0]] = Attribute.new(args[0], args[1]||{})
        self
      end

      # @api private
      def [](name)
        @attributes[name]
      end

    end # class AttributeSet
  end # class Mapper
end # module DataMapper
