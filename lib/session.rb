module Session
  class Session
    def insert(object)
      assert_not_loaded(object)
      @inserts[object]=true
    end

    def remove(object)
      assert_loaded(object)
      assert_not_update(object)
      @removes[object]=true
    end

    def update(object)
      assert_loaded(object)
      assert_not_remove(object)
      @updates[object]=true
    end

    def query(query)
      dumps = @adapter.read(query)
      dumps.map do |dump| 
        self.load(dump)
      end
    end

    def commit
      # TODO add some tsorting to do actions in 
      # correct order. Dependency source?
      do_removes
      do_updates
      do_inserts
    end

    def update?(object)
      @updates.key?(object)
    end

    def insert?(object)
      @inserts.key?(object)
    end

    def remove?(object)
      @removes.key?(object)
    end

    def loaded?(object)
      @loaded.key?(object)
    end

    def dirty_dump?(object,dump)
      !clean_dump?(object,dump)
    end

    def dirty?(object)
      !clean?(object)
    end

    def clean?(object)
      clean_dump?(object,@mapper.dump(object))
    end
    
  protected

    def clean_dump?(object,dump)
      assert_loaded(object)
      load_dump = @loaded.fetch(object)
      dump == load_dump
    end

    def load(dump,object=nil)
      key = @mapper.load_key(dump)
      unless @identity_map.key?(key)
        object ||= @mapper.load(dump)
        @loaded[object]=dump
        @identity_map[key]=object
        object
      else
        @identity_map.fetch(key)
      end
    end

    def initialize(options)
      @mapper = options.fetch(:mapper) do
        raise ArgumentError,'missing :mapper in +options+'
      end
      @adapter = options.fetch(:adapter) do
        raise ArgumentError,'missing :adapter in +options+'
      end
      # this looks dump
      @identity_map,@loaded,@inserts,@updates,@removes = {},{},{},{},{}
    end

    def do_insert(object)
      dump = @mapper.dump(object)
      @adapter.insert(dump)
      load(dump,object)
      @inserts.delete(object)
    end

    def do_inserts
      @inserts.keys.each do |object|
        do_insert(object)
      end
    end

    def do_update(object)
      dump = @mapper.dump(object)
      if dirty_dump?(object,dump)
        @adapter.update(dump)
        load(dump,object)
      end
      @updates.delete(object)
    end

    def do_updates
      @updates.keys.each do |object|
        do_update(object)
      end
    end

    def do_remove(object)
      dump = @mapper.dump(object)
      if dirty_dump?(object,dump)
        raise 'cannot remove dirty object'
      end
      @adapter.remove(dump)
      @loaded.delete(object)
    end

    def do_removes
      @removes.keys.each do |object|
        do_remove(object)
      end
    end

    def assert_loaded(object)
      unless loaded?(object)
        raise "object #{object.inspect} is not loaded"
      end
    end

    def assert_not_remove(object)
      if remove?(object)
        raise
      end
    end

    def assert_not_update(object)
      if update?(object)
        raise 
      end
    end

    def assert_not_loaded(object)
      if loaded?(object)
        raise
      end
    end
  end
end
