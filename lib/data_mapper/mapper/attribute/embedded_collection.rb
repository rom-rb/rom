module DataMapper
  class Mapper
    class Attribute

      class EmbeddedCollection < EmbeddedValue

        # @api public
        def load(tuple)
          tuple[field].map { |member| super(member) }
        end
      end # class EmbeddedCollection
    end # class Attribute
  end # class Mapper
end # module DataMapper
