module Session
  # A registry for mappers that can be passwd to a new session
  class Registry
    def initialize
      @data = {}
    end

    # Register a mapper for a model. Overrides existing registration.
    #
    # @param [Object] model the model
    # @param [Object] mapper the mapper
    #
    def register(model,mapper)
      @data[model] = mapper

      self
    end

    # Resolve a mapper for a given model.
    #
    # @param [Object] model the model
    # @return [Object] the mapper for given model
    # @raise [ArgumentError] in case mapper for model is not found. 
    #
    def resolve_model(model)
      @data.fetch(model) do
        raise ArgumentError,"mapper for #{model.inspect} is not registred"
      end
    end

    # Resolve a mapper for a given domain object. 
    # Uses objects class as model. @see #resolve_model
    #
    # @param [Object] object the object
    # @return [Object] the mapper for given object 
    #
    def resolve_object(object)
      resolve_model(object.class)
    end
  end
end
