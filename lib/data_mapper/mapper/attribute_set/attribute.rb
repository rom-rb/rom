module DataMapper
  class Mapper
    class AttributeSet

      # Attribute
      #
      # @api private
      class Attribute

        # @api private
        attr_reader :name

        # @api private
        attr_reader :type

        # @api private
        attr_reader :map_to

        # @api private
        def initialize(name, options = {})
          @name   = name
          @map_to = options.fetch(:to, @name)
          @type   = options.fetch(:type, Object)
        end

      end # class Attribute
    end # class AttributeSet
  end # class Mapper
end # module DataMapper
