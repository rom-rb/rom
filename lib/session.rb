module Session
  class Session
    attr_reader :adapter

    # I need these {remove,update,insert,update}_now methods for mongo 
    # where these # whole UoW does make "less sense" but the 
    # externalized state and dirtiness tracking is very 
    # valuable.
    #
    def remove_now(object)
      remove(object)
      commit

      self
    end

    def update_now(object)
      update(object)
      commit

      self
    end

    def insert_now(object)
      insert(object)
      commit

      self
    end

    def insert(object)
      assert_not_loaded(object)
      @inserts[object]=true

      self
    end

    def remove(object)
      assert_loaded(object)
      assert_not_update(object)
      @removes[object]=true

      self
    end

    def update(object)
      assert_loaded(object)
      assert_not_remove(object)
      @updates[object]=true

      self
    end

    def commit
      # TODO add some tsorting to do actions in 
      # correct order. Dependency source?
      do_removes
      do_updates
      do_inserts

      self
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

    def empty?
      @updates.empty? && @inserts.empty? && @removes.empty?
    end

    def dirty_dump?(object,dump)
      !clean_dump?(object,dump)
    end

    def dirty?(object)
      !clean?(object)
    end

    def unregister(object)
      @updates.delete(object)
      @removes.delete(object)
      @inserts.delete(object)
      if loaded?(object)
        intermediate = @loaded.delete(object)
        @identity_map.delete(load_key(object.class,intermediate))
      end

      self
    end

    def clean?(object)
      clean_dump?(object,@mapper.dump(object))
    end

    def clear
      # this looks dump
      # @identity_map tracks intermediate key representation to objects
      # @loaded tacks objects to intermediate representation
      @identity_map,@loaded,@inserts,@updates,@removes = {},{},{},{},{}

      self
    end


    
  protected

    def clean_dump?(object,dump)
      assert_loaded(object)
      load_dump = @loaded.fetch(object)
      dump == load_dump
    end

    def load(model,dump,object=nil)
      key = @mapper.for_model(model).load_key(dump)
      unless @identity_map.key?(key)
        object ||= @mapper.for_model(model).load(dump)
        @loaded[object]=dump
        @identity_map[key]=object
        object
      else
        # here we can check loaded dump 
        # against current dump and take action 
        # should we?
        @identity_map.fetch(key)
      end
    end

    def load_key(model,intermediate)
      @mapper.load_key(model,intermediate)
    end

    def initialize(options)
      @mapper = options.fetch(:mapper) do
        raise ArgumentError,'missing :mapper in +options+'
      end
      @adapter = options.fetch(:adapter) do
        raise ArgumentError,'missing :adapter in +options+'
      end
      clear
    end

    def do_inserts
      @inserts.each_key do |object|
        do_insert(object)
      end
    end

    def do_insert(object)
      dump = @mapper.dump(object)
      dump.each do |collection,record|
        @adapter.insert(collection,record)
      end
      load(object.class,dump,object)
      @inserts.delete(object)
    end

    def do_updates
      @updates.each_key do |object|
        do_update(object)
      end
    end

    # If you map your resource to "multiple" collections 
    # each colleciton level update will be passed isolated.
    # The adpaters do not know about the mapping.
    #
    def do_update(object)

      dump = @mapper.dump(object)
      old_dump = @loaded.fetch(object)
      old_key  = @mapper.load_key(old_dump) 

      # This is totally unspeced behaviour I need a multi collection 
      # mapping spec...
      dump.each_key do |collection|
        update_key = old_key.fetch(collection)
        old_record = old_dump.fetch(collection)
        new_record = dump.fetch(collection)
        # noop if no change
        unless new_record == old_record
          @adapter.update(collection,update_key,new_record,old_record)
        end
      end
      load(object.class,dump,object)
      @updates.delete(object)
    end

    def do_remove(object)
      dump = @mapper.dump(object)

      if dirty_dump?(object,dump)
        raise 'cannot remove dirty object'
      end

      key = @mapper.load_key(dump)

      key.each do |collection,dump|
        @adapter.remove(collection,dump)
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
