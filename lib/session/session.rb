# Namespace for session library
module Session
  # Represent a simple non UoW database session
  class Session
    # Read objects from database
    #
    # This method returns a mapper defined container that might be 
    # chainable. 
    # The container can use the passed block to load objects guarded by identity map.
    #
    # @example
    #   people = session.read(Person,:lastname => 'Doe')
    #
    # @param [Model] model
    #   the model to be queried
    #
    # @param [Object] query
    #   the query
    #
    # @return [Object] 
    #   the loaded objects wrapped by mapper defined query
    #
    # @api public
    #
    def read(model,query)
      mapper = @registry.resolve_model(model)
      mapper.new_query(query) do |dump|
        load(mapper,dump)
      end
    end

    # Delete a domain object from database an untrack
    #
    # @example
    #   person = session.first(Person)
    #   session.delete(person) # deletes person via person mapper
    #
    # @param [Object] object 
    #   the domain object to be deleted
    #
    # @return [self]
    #
    # @api public
    #
    def delete(object)
      track_state(state(object).delete)

      self
    end

    # Update a domain object in database
    #
    # If the object has changes these changes will be written to 
    # database. If the object is unchanged it is a noop.
    #
    # @example
    #   person = session.first(Person)
    #   person.lastname = 'Doe'
    #   session.update(person) # updates person via person mapper
    #
    # @param [Object] object the object to be updated
    #
    # @return [self]
    #
    # @api public
    #
    def update(object)
      state = state(object)
      @identity_map.delete(state.remote_key)
      track_state(state.update)

      self
    end

    # Insert or update a domain object depending on state
    #
    # Will behave like #insert if object is NOT tracked.
    # Will behave like #update if object is tracked.
    #
    # @example 
    #   # acts as #update
    #   person = session.first(Person)
    #   person.firstname = 'John'
    #   session.persist(person)
    #
    # @example
    #   # acts as #insert
    #   person = Person.new('John','Doe')
    #   session.persist(person)
    #
    # @param [Object] object the object to be persisted
    #
    # @return [self]
    #
    # @api public
    #
    def persist(object)
      state = @track.fetch(object) do
        new_state(object)
      end
      track_state(state.persist)

      self
    end

    # Returns whether an domain object is tracked in this session
    #
    # @example 
    #   session.track?(Object.new) # => false
    #   person = session.first(Person)
    #   session.track?(person)     # => true
    #
    # @param [Object] object 
    #   the domain object to be tested
    #
    # @return [true|false] 
    #   returns true when object is tracked
    #   false otherwitse
    #
    # @api public
    #
    def track?(object)
      @track.key?(object)
    end

    # Returns whether a domain object has changes since last sync with the database
    #
    # You normally should avoid calls to #clean? in favor of using #persist.
    #
    # @example
    #   person = Person.new(:firstname => 'John',:lastname => 'Doe')
    #   session.insert(person)
    #   session.dirty?(person) # => false
    #   person.firstname = 'Foo'
    #   session.dirty?(person) # => true
    #
    # @see #persist
    #
    # @param [Object] object 
    #   the domain object to be examined
    #
    # @return [true|false]
    #   returns true when there are changes in the object
    #   false otherwise
    #
    # @api public
    #
    def dirty?(object)
      !state(object).clean?
    end

    # Do not track a domain object anymore. 
    #
    # Should be used in batch operations to #unregister unneded objects to safe memory.
    #
    # @example
    #   session.all(Person).each do |person|
    #     person.mutate
    #     session.track?(person) # => true
    #     session.unregister(person)
    #     session.track?(person) # => false
    #   end
    #
    # @param [Object] object 
    #   the domain object to be untracked
    #
    # @return [self]
    #
    # @api public
    #
    def untrack(object)
      track_state(state(object).abandon)

      self
    end

  private

    # Initialize session with registry
    #
    # @param [Registry] registry 
    #
    # @return [self] 
    #
    # @api private
    #
    def initialize(registry)
      @registry     = registry
      @identity_map = {}
      @track        = {}

      self
    end

    # Load a domain object from dump and track
    #
    # @param [Mapper] mapper
    #   the mapper to load domain object with
    #
    # @param [Object] dump
    #   the dump representing domain object
    #
    # @return [Object]
    #   the loaded domain object
    #
    # @api private
    #
    def load(mapper,dump)
      key = mapper.load_key(dump)
      @identity_map.fetch(key) do
        state = ObjectState::Loaded.build(mapper,dump)
        track_state(state)
        state.object
      end
    end

    # Track object state in this session
    #
    # @param [ObjectState] state 
    #   the object state to be tracked.
    #
    # @return [self] 
    #
    # @api private
    #
    def track_state(state)
      state.update_track(@track)
      state.update_identity_map(@identity_map)

      self
    end

    # Return object state for domain object 
    #
    # @param [Object] object 
    # @raise [StateError] in case object is not tracked
    #
    # @return [ObjectState]
    #
    # @api private
    #
    def state(object)
      @track.fetch(object) do
        raise StateError,"#{object.inspect} is not tracked"
      end
    end

    # Initialize a ObjectState::New for domain object
    #
    # @param [Object] the domain object to be wrapped
    #
    # @return [ObjectState::New]
    #
    # @api private
    #
    def new_state(object)
      mapper = @registry.resolve_object(object)
      ObjectState::New.new(mapper,object)
    end
  end
end
