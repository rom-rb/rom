module DataMapper
  class Mapper
    class Attribute

      class Primitive < Attribute

        def initialize(name, options = {})
          super
          @type = options.fetch(:type, Object)
        end

        # @api private
        def header
          [ field, type ]
        end

        # @api public
        def load(tuple)
          tuple[field]
        end

      end # class Primitive

    end # class Attribute
  end # class Mapper
end # module DataMapper
