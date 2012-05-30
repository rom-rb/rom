# Namespace for session library
module Session
  # Represent a simple non UoW database session
  class Session
    # Insert domain object in database.
    #
    # @param [Object] object the object to be inserted
    #
    def insert(object)
      # FIXME: not using #track?(object) here fixes reek SimulatedPolymorphism
      # Needs to be decided.
      if @track.key?(object)
        raise "#{object.inspect} is already tracked and cannot be inserted"
      end

      state = new_state(ObjectState::New,object)
      state = state.insert
      track_state(state)


      self
    end

    # Delete a domain object from database an untrack.
    #
    # @param [Object] object the object to be deleted
    #
    def delete(object)
      state = state(object)
      state.delete

      untrack_state(state)

      self
    end

    # Update a domain object in database.
    #
    # If the object has changes these changes will be written to 
    # database. If the object is unchanged it is a noop.
    #
    # @param [Object] object the object to be updated
    #
    def update(object)
      state = state(object)
      @identity_map.delete(state.remote_key)
      track_state(state.update)

      self
    end

    # Insert or update a domain object depending on state.
    #
    # Will behave like #insert if object is NOT tracked.
    # Will behave like #update if object is tracked.
    #
    # @param [Object] object the object to be persisted
    #
    def persist(object)
      if track?(object)
        update(object)
      else
        insert(object)
      end

      self
    end

    # Returns whether an domain object is tracked in this session
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

    # Returns whether a domain object has changes since last sync with the database.
    # Returns the opposite of #clean?(object)
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

    # Returns whether a domain object has NO changes since last sync with the database.
    # Returns the opposite of #dirty?(object) 
    #
    # @param [Object] object the object to be examined
    #
    # @return [true|false]
    #   returns true when there are changes in the object
    #   false otherwise
    #
    def clean?(object)
      state(object).clean?
    end

    # Do not track a domain object anymore. Any uncommitted work on this 
    # object is lost.
    #
    # Does nothing if this object was not tracked before
    #
    # @param [Object] object the object to be untracked
    #
    def untrack(object)
      state = @track[object]

      if state
        untrack_state(state)
      end

      self
    end

  protected

    def initialize(registry)
      @registry     = registry
      @identity_map = {}
      @track        = {}

      self
    end

    def track_state(state)
      object = state.object
      @track[object]=state
      @identity_map[state.remote_key]=object
    end

    def untrack_state(state)
      @track.delete(state.object)
      @identity_map.delete(state.remote_key)
    end

    def state(object)
      @track.fetch(object) do
        raise "#{object.inspect} is not tracked"
      end
    end

    def new_state(state,object)
      mapper = @registry.resolve_object(object)
      state.new(mapper,object)
    end
  end
end
