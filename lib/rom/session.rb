module ROM

  # A database session
  class Session
    include Adamantium::Flat, Concord.new(:registry, :tracker)

    public :tracker

    # @api private
    def self.new(registry, tracker = {})
      super(registry, tracker)
    end

    # Return model specific reader
    #
    # The container can use the passed block to load objects guarded by identity map.
    #
    # @example
    #   people = session.read(Person, :lastname => 'Doe')
    #
    # @param [Class] model
    #   the domain model class to be queried
    #
    # @return [Reader]
    #   a reader for instances of +model+
    #
    # @api public
    def reader(model)
      mapper = registry.resolve_model(model)
      Reader.new(self, mapper)
    end

    # Delete a domain object from the database and forget it
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
    def delete(object)
      state = state(object)
      old = old(state)
      old.delete
      tracker.delete(old.identity)

      self
    end

    # Test whether a domain object is tracked in this session
    #
    # @example
    #   person = Person.new
    #   session.include?(person) # => false
    #   session.persist(person)
    #   session.include?(person) # => true
    #
    # @param [Object] object
    #   the domain object to be examined
    #
    # @return [true]
    #   if +object+ is tracked
    #
    # @return [false]
    #   otherwise
    #
    # @api public
    def include?(object)
      state = state(object)
      tracker.key?(state.identity)
    end

    # Returns whether a domain object has changes since last sync with the database
    #
    # You normally should avoid calls to #dirty? in favor of using #persist.
    #
    # @example
    #   person = Person.new(:firstname => 'John', :lastname => 'Doe')
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
    # @return [true]
    #   if there are changes in the object
    #
    # @return [false]
    #   otherwise
    #
    # @api public
    def dirty?(object)
      state = state(object)
      old = old(state)
      state.dirty?(old)
    end

    # Do not track a domain object anymore
    #
    # Should be used in batch operations to unregister objects that are not needed anymore.
    #
    # In case you iterate about too many objects using the same session all iterated objects
    # stay referenced in the identity map and state tracking.
    #
    # @example
    #   session.read(Person).each do |person|
    #     person.mutate
    #     # This will allow ruby to gc person.
    #     session.forget(person)
    #   end
    #
    # @param [Object] object
    #   the domain object to be forgotten
    #
    # @return [self]
    #
    # @api public
    def forget(object)
      state = state(object)
      tracker.delete(state.identity)

      self
    end

    # Load a domain object from tuple and track it
    #
    # Will return already tracked object in case of identity map collision.
    #
    # @param [Loader] loader
    #   the loader for domain object
    #
    # @return [Object]
    #   the loaded domain object
    #
    # @api private
    def load(loader)
      tracker.fetch(loader.identity) do
        store(State::Loaded.new(loader))
      end.object
    end

    # Insert or update a domain object depending on state
    #
    # Will insert object if NOT tracked.
    # Will update object if tracked.
    #
    # @example acting as update
    #   person = session.first(Person)
    #   person.firstname = 'John'
    #   session.persist(person)
    #
    # @example acting as insert
    #   person = Person.new('John', 'Doe')
    #   session.persist(person)
    #
    # @param [Object] object
    #   the object to be persisted
    #
    # @return [self]
    #
    # @api public
    def persist(object)
      util = tracker
      state = state(object)
      identity = state.identity
      if util.key?(identity)
        state.update(util.fetch(identity))
      else
        state.insert
      end
      store(state)
      self
    end

    # Return old state for state
    #
    # @param [State] state
    #   the state for which to retrieve the old state
    #
    # @return [State]
    #   if object is associated with a state
    #
    # @raise [StateError]
    #   in case object is not tracked
    #
    # @api private
    def old(state)
      tracker.fetch(state.identity) do
        raise StateError, "#{state.object.inspect} is not tracked"
      end
    end

    # Store and return state
    #
    # @param [State] state
    #   the state to store
    #
    # @return [State]
    #   the stored state
    #
    # @api private
    def store(state)
      tracker.store(state.identity, state)
    end

    # Return state for object
    #
    # @param [Object] object
    #   a domain model instance
    #
    # @return [State]
    #   a state instance wrapping +object+
    #
    # @api private
    def state(object)
      mapper = registry.resolve_object(object)
      State.new(mapper, object)
    end

  end # Session
end # ROM
