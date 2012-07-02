module DataMapper
  class Mapper
    class Attribute

      class Collection < Mapper

        # @api public
        def load(tuple)
          tuple[field].map { |member| super(member) }
        end

      end # class Collection

    end # class Attribute
  end # class Mapper
end # module DataMapper
