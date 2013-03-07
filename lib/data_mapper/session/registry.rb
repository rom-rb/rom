module DataMapper
  class Session

    # A registry for mappers session uses to find mappers
    class Registry
      include Adamantium::Flat, Equalizer.new(:index)

      # Return index
      #
      # @return [Hash<Class, Mapper>]
      #
      # @api private
      attr_reader :index

      # Initialize an empty mapper registry
      #
      # @example
      #   registry = Registry.new(Person => Person::Mapper)
      #   session = Session.new(registry)
      #
      # @api public
      def initialize(index)
        @index = index
      end

      # Resolve the mapper for the given +model+
      #
      # @example
      #   registry = Registry.new(Person => Person::Mapper)
      #   registry.resolve_model(Person) # => Person::Mapper
      #   registry.resolve_model(UnmappedModel) # raises ArgumentError
      #
      # @param [Class] model
      #   a domain model class
      #
      # @return [Mapper]
      #   the mapper for the given +model+
      #
      # @raise [MissingMapperError]
      #   in case no mapper for +model+ can be found
      #
      # @api public
      #
      def resolve_model(model)
        @index.fetch(model) do
          raise MissingMapperError, "Mapper for: #{model.inspect} is not registred"
        end
      end

      # Resolve a mapper for a given domain +object+
      #
      # Uses objects class as model. @see #resolve_model
      #
      # @example
      #   registry = Registry.new(Person => Person::Mapper)
      #   person = Peron.new('John', 'Doe')
      #   registry.resolve_object(person)     # => Person::Mapper
      #   registry.resolve_object(Object.new) # raises ArgumentError
      #
      # @param [Object] object
      #   a domain model instance
      #
      # @return [Mapper]
      #   the mapper for the given +object+
      #
      # @api public
      def resolve_object(object)
        resolve_model(object.class)
      end
    end
  end
end
