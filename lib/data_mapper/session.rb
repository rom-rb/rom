module DataMapper
  # A database session
  class Session
    include Adamantium::Flat, Equalizer.new(:registry)

    # Return registry
    #
    # @return [Registry]
    #
    # @api private
    #
    attr_reader :registry

    # Return model specific reader
    #
    # The container can use the passed block to load objects guarded by identity map.
    #
    # @example
    #   people = session.read(Person, :lastname => 'Doe')
    #
    # @param [Model] model
    #   the model to be queried
    #
    # @return [Reader]
    #   a reader for specific model
    #
    # @api public
    #
    def reader(model)
      mapper = @registry.resolve_model(model)
      Reader.new(self, mapper) 
    end

    # Delete a domain object from database and forget it
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
      state = state(object)
      state.delete
      @tracker.delete(state.identity)

      self
    end

    # Insert or update a domain object depending on state
    #
    # Will insert object if NOT tracked.
    # Will update object if tracked.
    #
    # @example
    #   # acts as update
    #   person = session.first(Person)
    #   person.firstname = 'John'
    #   session.persist(person)
    #
    # @example
    #   # acts as insert
    #   person = Person.new('John', 'Doe')
    #   session.persist(person)
    #
    # @param [Object] object
    #   the object to be persisted
    #
    # @return [self]
    #
    # @api public
    #
    def persist(object)
      mapping = mapping(object)
      state = @tracker.fetch(mapping.identity) do
        State::New.new(mapping)
      end
      @tracker.store(state.persist)

      self
    end

    # Returns whether an domain object is tracked in this session
    #
    # @example
    #   person = Person.new
    #   session.include?(person) # => false
    #   session.persist(person)
    #   session.include?(person) # => true
    #
    # @param [Object] object
    #   the domain object to be tested
    #
    # @return [true|false]
    #   when object is tracked
    #
    # @return [false]
    #   otherwitse
    #
    # @api public
    #
    def include?(object)
      @tracker.include?(identity(object))
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
    #   when there are changes in the object
    #
    # @return [false]
    #   otherwise
    #
    # @api public
    #
    def dirty?(object)
      state(object).dirty?
    end

    # Do not track a domain object anymore
    #
    # Should be used in batch operations to unregister objects that are not needed anymore.
    #
    # In case you iterate about to many objects using the same session all iterated objects
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
    #
    def forget(object)
      state = state(object)

      @tracker.delete(state.identity)

      self
    end

    # Load a domain object from tuple and track it
    #
    # Will return already tracked object in case of identity map collision.
    #
    # @param [Mapper] mapper
    #   the mapper to load domain object with
    #
    # @param [Object] tuple
    #   the tuple representing domain object
    #
    # @return [Object]
    #   the loaded domain object
    #
    # @api private
    #
    def load(mapper, tuple)
      state = State::Loading.new(mapper, tuple)

      @tracker.fetch(state.identity) do
        state = state.loaded
        @tracker.store(state)
        state
      end.object
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
      @tracker      = Tracker.new

      self
    end

    # Return object state for domain object
    #
    # @param [Object] object
    #
    # @return [State]
    #   if object is associated with a state
    #
    # @raise [StateError] 
    #   in case object is not tracked
    #
    # @api private
    #
    def state(object)
      identity = identity(object)
      @tracker.fetch(identity) do
        raise StateError, "#{object.inspect} is not tracked"
      end
    end

    # Return identity for object
    #
    # @param [Object] object
    #
    # @return [Object]
    #   identity of object
    #
    # @api private
    #
    def identity(object)
      mapping(object).identity
    end

    # Return mapping for object
    #
    # @param [Object] object
    #
    # @return [Mapping]
    #
    # @api private
    #
    def mapping(object)
      mapper = @registry.resolve_object(object)
      Mapping.new(mapper, object)
    end
  end
end
