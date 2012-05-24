module Session
  # A class to represent a database session.
  class Session
    # Register a domain object for beeing inserted # on commit of this session
    #
    # @param [Object] object the object to be inserted
    #
    def insert(object)
      if track?(object)
        raise "#{object.inspect} is already tracked and cannot be marked for insert"
      end

      @inserts.add(object)

      self
    end

    # Register a domain object for beeing deleted on commit of this session
    #
    # @param [Object] object the object to be deleted
    #
    def delete(object)
      assert_track(object)

      @updates.delete(object)
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

      @deletes.delete(object)
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
      tracked_dump(object) == @registry.dump_object(object)
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
        @identity_map.delete(@registry.load_object_key(object,dump))
      end

      self
    end

  protected

    # Track an object in this session
    #
    # The objects identity based on mapped key and the objects dumped state are
    # track from now.
    #
    # @param [Object] the object to be track
    #
    def track(object)
      dump = @registry.dump_object(object)
      key  = @registry.dump_object_key(object)

      track_dump(object,dump,key)

      self
    end

    # Track an object with known dump
    def track_dump(object,dump,key)
      @track[object]=dump
      @identity_map[key]=object

      self
    end

    def tracked_dump(object)
      @track.fetch(object)
    end

    def initialize(mapper)
      @registry = mapper
      @identity_map = {}
      @track        = {}
      @inserts      = Set.new
      @updates      = Set.new
      @deletes      = Set.new

      self
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
      @registry.insert_object(object)
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
      old_dump = tracked_dump(object)

      Operation::Update.run(self,object,old_dump)

      @updates.delete(object)

      self
    end

    def do_delete(object)
      key = @registry.dump_object_key(object)

      @registry.delete_object_key(object,key)

      untrack(object)

      self
    end

    def assert_track(object)
      unless track?(object)
        raise "#{object.inspect} is not tracked"
      end
      
      self
    end

  end
end
