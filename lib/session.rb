module Session
  class Session
    # Update domain object and commit this session
    #
    # @param [Object] object the object to be updated
    #
    def update_now(object)
      assert_committed
      update(object)
      commit
      
      self
    end

    # Delete domain object and commit this session
    #
    # @param [Object] object the object to be deleted
    #
    def delete_now(object)
      assert_committed
      delete(object)
      commit
      
      self
    end

    # Insert domain object and commit this session
    #
    # @param [Object] object the object to be inserted
    #
    def insert_now(object)
      assert_committed
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
      # TODO add some tsorting to do actions on domain objects in 
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
    #   returns true when object was marked as to be updated
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
    #   returns true when object was marked as to be inserted
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
    #   returns true when object was marked as to be deleted
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
    #   returns true when object is tracked
    #   false otherwitse
    #
    def track?(object)
      @track.key?(object)
    end

    # Returns whether this session has any uncommited work
    #
    # @param [Object] object the object to be examined
    #
    # @return [true|false] 
    #   returns true when there is uncommitted work
    #   false otherwitse
    #
    def uncommitted?
      !committed?
    end

    # Returns whether this session is fully commited
    #
    # @param [Object] object the object to be examined
    #
    # @return [true|false] 
    #   returns true when there is no uncommitted work
    #   false otherwitse
    #
    def committed?
      @updates.empty? && @inserts.empty? && @deletes.empty?
    end

    # Returns whether a domain object has changes since tracking begun
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

    # Returns whether a domain object has NO changes since tracking begun
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

    # Do not track a domain object anymore. Any uncommitted work on this 
    # object is lost.
    #
    # Does nothing if this object was not known
    #
    # @param [Object] object the object to be untracked
    #
    def untrack(object)
      @updates.delete(object)
      @deletes.delete(object)
      @inserts.delete(object)

      if track?(object)
        dump = @track.delete(object)
        @identity_map.delete(@mapper.load_object_key(object,dump))
      end

      self
    end

    # Clears this sessions. All information about track objects and uncommitted 
    # work is lost
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

    # Returns whether a domain object is dirty from mappers point of view.
    #
    # @param [Object] object the domain object to be tested for dirtiness
    # @param [Object] the dumped representation of object
    #
    # @return [true|false]
    #   return true if the current dumped representation does not match the 
    #   provided representation
    #
    def dirty_dump?(object,dump)
      !clean_dump?(object,dump)
    end

    # Returns whester a domain object is NOT dirty from mappers point of view.
    #
    # @param [Object] object the object to be tested
    # @param [Object] the dumped representaion of object
    #
    def clean_dump?(object,dump)
      assert_track(object)
      stored_dump = @track.fetch(object)
      dump == stored_dump
    end

    # Track an object in this session
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

    # Load and create an object form dump this method checks identity map 
    # using the identity in dump to make sure it creates no duplicate
    #
    # @param [Mapper] mapper of object
    # @param [Object] dump of object
    #
    # @return [Object] domain object
    #
    def load(model,dump)
      key = mapper.load_model_key(model,dump)
      if @identity_map.key?(key)
        @identity_map.fetch(key)
      else
        object = mapper.load(dump)
        track(object)
        object
      end
    end

    def initialize(mapper)
      @mapper = mapper
      clear
    end

    def do_deletes
      @deletes.keys.each do |object|
        do_delete(object)
      end

      self
    end

    def do_inserts
      @inserts.each_key do |object|
        do_insert(object)
      end

      self
    end

    def do_insert(object)
      @mapper.insert(object)
      track(object)
      @inserts.delete(object)

      self
    end

    def do_updates
      @updates.each_key do |object|
        do_update(object)
      end

      self
    end

    # If you map your resource to "multiple" collections 
    # each colleciton level update will be passed isolated.
    # The adpaters do not know about the mapping.
    #
    def do_update(object)
      old_dump = @track.fetch(object)

      new_dump = @mapper.dump(object)

      unless new_dump == old_dump
        old_key  = @mapper.load_object_key(object,old_dump) 
        @mapper.update(object,old_key,old_dump)
        @identity_map.delete(old_key)
        track(object)
      end

      @updates.delete(object)

      self
    end

    def do_delete(object)
      if dirty?(object)
        raise 'cannot delete dirty object'
      end

      key = @mapper.dump_key(object)

      @mapper.delete(object)

      untrack(object)

      self
    end

    def assert_track(object)
      unless track?(object)
        raise "object #{object.inspect} is not tracked"
      end
      
      self
    end

    def assert_committed
      unless committed?
        raise 'session is not comitted'
      end

      self
    end


    def assert_not_delete(object)
      if delete?(object)
        raise "object #{object.inspect} is marked as to be deleted"
      end

      self
    end

    def assert_not_update(object)
      if update?(object)
        raise "object #{object.inspect} is marked as to be updated"
      end

      self
    end

    def assert_not_track(object)
      if track?(object)
        raise "object #{object.inspect} is tracked"
      end

      self
    end
  end
end
