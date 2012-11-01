module DataMapper
  class Mapper
    class Attribute

      class Primitive < Attribute

        # Initialize a new primitive attribute instance
        #
        # @see Attribute#initialize
        #
        # @return [undefined]
        #
        # @api private
        def initialize(name, options = {})
          super
          @type = options.fetch(:type, Object)
        end

        # The attribute's human readable representation
        #
        # @example
        #
        #   attribute = DataMapper[Person].attributes[:name]
        #   puts attribute.inspect
        #
        # @return [String]
        #
        # @api public
        def inspect
          "<##{self.class.name} @name=#{name} @type=#{type} @field=#{field} @key=#{key?}>"
        end

        # The attribute's representation within a relation header
        #
        # @return [Array(Symbol, Class)]
        #
        # @api private
        def header
          [ field, type ]
        end

        # Load this attribute's value from a tuple
        #
        # @param [(#each, #[])] tuple
        #   the tuple to load
        #
        # @return [Object]
        #
        # @api private
        def load(tuple)
          tuple[field]
        end

        # Tests wether this attribute is primitive or not
        #
        # @return [Boolean]
        #   true if this is a primitive attribute, false otherwise
        #
        # @api private
        def primitive?
          true
        end

      end # class Primitive
    end # class Attribute
  end # class Mapper
end # module DataMapper
