module DataMapper
  class Mapper
    class Attribute

      class Primitive < Attribute

        def initialize(name, options = {})
          super
          @type = options.fetch(:type, Object)
        end

        # @api public
        def inspect
          "<##{self.class.name} @name=#{name} @type=#{type} @field=#{field} @key=#{key?}>"
        end

        # @api private
        def header
          [ field, type ]
        end

        # @api public
        def load(tuple)
          tuple[field]
        end

        # @api private
        def primitive?
          true
        end

      end # class Primitive

    end # class Attribute
  end # class Mapper
end # module DataMapper
