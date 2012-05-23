module Session
  class Session
    def all(model,query)
      mapper = @mapper.for(model)
      dumps = mapper.read_dumps(query)
      Enumerator.new do |yielder|
        dumps.each do |dump|
          yielder.yield load(model,dump)
        end
      end
    end

    def first(model,query)
      mapper = @mapper.for(model)
      key = mapper.extract_key_from_query(query)
      @identity_map.fetch(key) do
        dump = mapper.first_dump(query)
        if dump
          load(model,dump)
        end
      end
    end

    # Persist domain object and commit this session
    #
    # @param [Object] object the object to be updated
    #
    def persist_now(object)
      assert_committed
      persist(object)
      commit
      
      self
    end

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
      @inserts.add(object)

      self
    end

    # Register a domain object for beeing deleted on commit of this session
    #
    # @param [Object] object the object to be deleted
    #
    def delete(object)
      assert_track(object)
      assert_not_update(object)
      @deletes.add(object)

      self
    end

    # Register a domain object for beeing inserted or updated
    #
    # @param [Object] object the object to be persisted
    def persist(object)
      if track?(object)
        update(object)
      else
        insert(object)
      end

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
      @updates.add(object)

      self
    end

    # Commit all changes
    #
    # Commits all changes to the database, currently there is no support for 
    # transactions.
    #
    def commit
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
      @updates.member?(object)
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
      @inserts.member?(object)
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
      @deletes.member?(object)
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
      @track.member?(object)
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
      @track        = {}
      @inserts      = Set.new
      @updates      = Set.new
      @deletes      = Set.new

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
     #@track[object]=@mapper.dump(object)
     #key = @mapper.dump_key(object)
     #@identity_map[key]=object
      track_dump(object,@mapper.dump(object),@mapper.dump_key(object))

      self
    end

    # Track an object with known dump
    def track_dump(object,dump,key)
      @track[object]=dump
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
      key = @mapper.load_model_key(model,dump)
      @identity_map.fetch(key) do
        object = @mapper.load_model(model,dump)
        track_dump(object,dump,@mapper.dump_key(object))
        object
      end
    end

    def initialize(mapper)
      @mapper = mapper
      clear
    end

    def do_deletes
      @deletes.each do |object|
        do_delete(object)
      end

      self
    end

    def do_inserts
      @inserts.each do |object|
        do_insert(object)
      end

      self
    end

    def do_insert(object)
      @mapper.insert_object(object)
      track(object)
      @inserts.delete(object)

      self
    end

    def do_updates
      @updates.each do |object|
        do_update(object)
      end

      self
    end

    def do_update(object)
      if dirty?(object)
        old_dump = @track.fetch(object)
        old_key  = @mapper.load_object_key(object,old_dump) 
        @mapper.update_object(object,old_key,old_dump)
        untrack(object)
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

      @mapper.delete_object_key(object,key)

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
