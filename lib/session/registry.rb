module Session
  # A registry for mappers that can be passwd to a new session
  class Registry
    def initialize
      @data = {}
    end

    def register(model,mapper)
      @data[model] = mapper

      self
    end

    def resolve_model(model)
      @data.fetch(model) do
        raise ArgumentError,"model #{model.inspect} is not registred"
      end
    end

    def resolve_object(object)
      resolve_model(object.class)
    end

    def load_model(model,dump)
      resolve_model(model).load(dump)
    end

    def load_model_key(model,dump)
      resolve_model(model).load_key(dump)
    end

    def insert_object(object)
      resolve_object(object).insert_object(object)
    end

    def delete_object_key(object,key)
      resolve_object(object).delete(key)
    end

    def load_object_key(object,dump)
      resolve_object(object).load_key(dump)
    end

    def dump_object(object)
      resolve_object(object).dump(object)
    end

    def dump_object_key(object)
      resolve_object(object).dump_key(object)
    end
  end
end
