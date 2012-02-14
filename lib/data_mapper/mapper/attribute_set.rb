module DataMapper
  class Mapper

    # AttributeSet
    #
    # @api private
    class AttributeSet

      # @api private
      def initialize
        @_attributes = {}
      end

      # @api private
      def header
        @header ||= @_attributes.values.map do |attribute|
          [ attribute.field, attribute.type ]
        end
      end

      # @api private
      def map(tuple)
        @_attributes.values.each_with_object({}) do |attribute, attributes|
          attributes[attribute.name] = tuple[attribute.field]
        end
      end

      # @api private
      def add(*args)
        @_attributes[args[0]] = Attribute.new(args[0], args[1]||{})
        self
      end

      # @api private
      def [](name)
        @_attributes[name]
      end

    end # class AttributeSet
  end # class Mapper
end # module DataMapper
