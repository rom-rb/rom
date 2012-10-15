module DataMapper
  # A registry for mappers session uses to find mappers
  class Registry
    include Adamantium

    # Initialize an empty mapper registry
    #
    # @example
    #   registry = Registry.new(Person => Person::Mapper)
    #   session = Session.new(registry)
    #
    # @api public
    #
    def initialize(index)
      @index = index
    end

    # Resolve a mapper for a given model
    #
    # @example
    #   registry = Registry.new(Person => Person::Mapper)
    #   registry.resolve_model(Person) # => Person::Mapper
    #   registry.resolve_model(UnmappedModel) # raises ArgumentError
    #
    # @param [Object] model
    #
    # @return [Object]
    #   the mapper for given model
    #
    # @raise [ArgumentError] in case mapper for model is not found.
    #
    # @api public
    #
    def resolve_model(model)
      @index.fetch(model) do
        raise ArgumentError, "mapper for #{model.inspect} is not registred"
      end
    end

    # Resolve a mapper for a given domain object
    #
    # Uses objects class as model. @see #resolve_model
    #
    # @example
    #   registry = Registry.new(Person, Person::Mapper)
    #   person = Peron.new('John', 'Doe')
    #   registry.resolve_object(person) # => Person::Mapper
    #   registry.resolve_object(Object.new) # raises ArgumentError
    #
    # @param [Object] object
    #
    # @return [Object]
    #   the mapper for given object
    #
    # @api public
    #
    def resolve_object(object)
      resolve_model(object.class)
    end
  end
end
