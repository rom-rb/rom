module Session
  class Session
    attr_reader :adapter

    # Update domain object and commit this session
    #
    # @param [Object] object the object to be updated
    #
    def update_now(object)
      update(object)
      commit
      
      self
    end

    # Delete domain object and commit this session
    #
    # @param [Object] object the object to be deleted
    #
    def delete_now(object)
      delete(object)
      commit
      
      self
    end

    # Insert domain object and commit this session
    #
    # @param [Object] object the object to be inserted
    #
    def insert_now(object)
      insert(object)
      commit
      
      self
    end

    # Register a domain object for beeing inserted # on commit of this session
    #
    # @param [Object] object the object to be inserted
    #
    def insert(object)
      assert_not_track(object)
      @inserts[object]=true

      self
    end

    # Register a domain object for beeing deleted on commit of this session
    #
    # @param [Object] object the object to be deleted
    #
    def delete(object)
      assert_track(object)
      assert_not_update(object)
      @deletes[object]=true

      self
    end

    # Register a domain object for beeing updated on commit of this session 
    #
    # If the object has changes on commit these changes will be written to 
    # database. If the object is unchanged it is a noop.
    #
    # @param [Object] object the object to be updated
    #
    def update(object)
      assert_track(object)
      assert_not_delete(object)
      @updates[object]=true

      self
    end

    # Commit all changes
    #
    # Commits all changes to the database, currently there is no support for 
    # transactions.
    #
    def commit
      # TODO add some tsorting to do actions in 
      # correct order. Dependency source?
      do_deletes
      do_updates
      do_inserts

      self
    end

    # Returns whether an domain object registered for update
    #
    # @param [Object] object the object to be examined
    #
    # @return [true|false] 
    #   returns true when object was registred for update 
    #   false otherwitse
    #
    def update?(object)
      @updates.key?(object)
    end

    # Returns whether an domain object registered for insert
    #
    # @param [Object] object the object to be examined
    #
    # @return [true|false] 
    #   returns true when object was registred for insert 
    #   false otherwitse
    #
    def insert?(object)
      @inserts.key?(object)
    end

    # Returns whether an domain object registered for delete
    #
    # @param [Object] object the object to be examined
    #
    # @return [true|false] 
    #   returns true when object was registred for delete 
    #   false otherwitse
    #
    def delete?(object)
      @deletes.key?(object)
    end

    # Returns whether an domain object is track in this session
    #
    # @param [Object] object the object to be examined
    #
    # @return [true|false] 
    #   returns true when object was registred for delete 
    #   false otherwitse
    #
    def track?(object)
      @track.key?(object)
    end

    # Returns whether the sessions has any pending changes registred
    #
    # @param [Object] object the object to be examined
    #
    # @return [true|false] 
    #   returns true when there are pending changes
    #   false otherwitse
    #
    def empty?
      @updates.empty? && @inserts.empty? && @deletes.empty?
    end

    # Returns whether a domain object has changes since it was track
    #
    # @param [Object] object the object to be examined
    #
    # @return [true|false]
    #   returns true when there are changes in the object
    #   false otherwise
    #
    def dirty?(object)
      !clean?(object)
    end

    # Returns whether a domain object has NO changes since it was track
    #
    # @param [Object] object the object to be examined
    #
    # @return [true|false]
    #   returns true when there are changes in the object
    #   false otherwise
    #
    def clean?(object)
      clean_dump?(object,@mapper.dump(object))
    end

    # Unregisters a domain object from this session. Pending changes are lost.
    #
    # Does nothing if this object was not known
    #
    # @param [Object] object the object to be unregistred
    #
    def unregister(object)
      @updates.delete(object)
      @deletes.delete(object)
      @inserts.delete(object)
      if track?(object)
        intermediate = @track.delete(object)
        @identity_map.delete(@mapper.load_key(object.class,intermediate))
      end

      self
    end

    # Clears this sessions. All information about track objects and registred 
    # actions are lost.
    #
    # TODO: Using hashes<Object,Boolean> as action registry is a poor 
    # man solution. A ruby set class can do the job also.
    #
    def clear
      @identity_map = {}
      @track       = {}
      @inserts      = {}
      @updates      = {}
      @deletes      = {}

      self
    end

  protected

    # Returns whether a dumped object representation of an domain object is 
    # dirty
    #
    # @param [Object] object the domain object to be tested
    # @param [Object] the dumped representation of object
    #
    # @return [true|false]
    #   return true if the current dumped representation does not match the 
    #   provided representation
    #
    def dirty_dump?(object,dump)
      !clean_dump?(object,dump)
    end

    # Returns whester a dumped object representation of an domain object is
    # still the same since it was track
    #
    # @param [Object] object the object to be tested
    # @param [Object] the dumped representaion of object
    #
    def clean_dump?(object,dump)
      assert_track(object)
      stored_dump = @track.fetch(object)
      dump == stored_dump
    end

    # Track an object 
    #
    # The objects identity based on mapped key and the objects dumped state are
    # track from now.
    #
    # @param [Object] the object to be track
    #
    def track(object)
      @track[object]=@mapper.dump(object)
      key = @mapper.dump_key(object)
      @identity_map[key]=object

      self
    end

    # Loads and creates an object form dump
    # If dump contains an identity mapped object the 
    # object will not be created.
    #
    def load(model,dump)
      key = @mapper.load_key(model,dump)
      if @identity_map.key?(key)
        @identity_map.fetch(key)
      else
        object = @mapper.load(model,dump)
        track(object)
        object
      end
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
      track(object)
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
      old_dump = @track.fetch(object)
      old_key  = @mapper.load_key(object.class,old_dump) 

      # TODO:
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
      track(object)
      @updates.delete(object)
    end

    def do_delete(object)
      dump = @mapper.dump(object)

      if dirty_dump?(object,dump)
        raise 'cannot delete dirty object'
      end

      key = @mapper.load_key(object.class,dump)

      key.each do |collection,dump|
        @adapter.delete(collection,dump)
      end

      @track.delete(object)
    end

    def do_deletes
      @deletes.keys.each do |object|
        do_delete(object)
      end
    end

    def assert_track(object)
      unless track?(object)
        raise "object #{object.inspect} is not track"
      end
    end

    def assert_not_delete(object)
      if delete?(object)
        raise "object #{object.inspect} is registred to be deleted"
      end
    end

    def assert_not_update(object)
      if update?(object)
        raise "object #{object.inspect} is registred to be updated"
      end
    end

    def assert_not_track(object)
      if track?(object)
        raise "object #{object.inspect} is tracked"
      end
    end
  end
end
