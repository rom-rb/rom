module DataMapper
  class Mapper
    class Attribute

      class Mapper < Attribute

        def initialize(name, options = {})
          super
          @type = options.fetch(:type)
        end

        # @api public
        def finalize
          @mapper = DataMapper[type]
        end

        # @api public
        def load(tuple)
          @mapper.load(tuple)
        end

      end # class Mapper

    end # class Attribute
  end # class Mapper
end # module DataMapper
