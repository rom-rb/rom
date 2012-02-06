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

    def load(query)
      objects = []
      @mapper.affected_repo_names(query).each do |name|
        adapter = @adapters.fetch(name)
        dumps = adapter.read(query)
        dumps.each do |dump| 
          objects << @mapper.load(name => dump)
        end
      end
      objects
    end

    def commit
      # TODO add some tsorting to save in 
      # correct order.
      do_removes
      do_updates
      do_inserts
    end

    def update?(object)
      @updates.key?(object)
    end

    def new?(object)
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
    
    def clean_dump?(object,dump)
      assert_loaded(object)
      load_dump = @loaded.fetch(object)
      dump == load_dump
    end

  private

    def initialize(options)
      @mapper = options.fetch(:mapper) do
        raise ArgumentError,'missing :mapper in +options+'
      end
      @adapters = options.fetch(:adapters) do
        raise ArgumentError,'missing :adapter in +options+'
      end
      @loaded,@inserts,@updates,@removes = {},{},{},{}
    end

    def adapter_for(key)
      @adapters.fetch(key) do 
        raise "no adapter for #{key.inspect} is configured"
      end
    end

    def do_insert(object)
      dumped = @mapper.dump(object)
      dumped.each do |key,data|
        adapter = adapter_for(key)
        adapter.insert(data)
      end
      @loaded[object]=dumped
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
        dump.each do |adapter_name,data|
          adapter = adapter_for(adapter_name)
          adapter.update(data)
        end
        @loaded[object]=dump
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
      dump.each do |key,data|
        adapter = adapter_for(key)
        adapter.remove(data)
      end
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
