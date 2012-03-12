module Session
  class Registry
    def initialize
      @data = {}
    end

    def register(model,mapper)
      @data[model] = mapper

      self
    end

    def for(model)
      @data.fetch(model)
    end

    def for_object(object)
      self.for(object.class)
    end

    def load_model(model,dump)
      self.for(model).load(dump)
    end

    def load_model_key(model,dump)
      self.for(model).load_key(dump)
    end

    def insert_object(object)
      self.for_object(object).insert_object(object)
    end

    def update_object(object,old_key,old_dump)
      new_dump = dump(object)
      self.for_object(object).update_dump(old_key,new_dump,old_dump)
    end

    def delete_object_key(object,key)
      self.for_object(object).delete_key(key)
    end

    def load_object_key(object,dump)
      self.for_object(object).load_key(dump)
    end

    def dump(object)
      self.for_object(object).dump(object)
    end

    def dump_key(object)
      self.for_object(object).dump_key(object)
    end

    def load(model,dump)
      self.for(model).load(dump)
    end

    def load_key(model,dump)
      self.for(model).load_key(dump)
    end
  end
end
