module DataMapper
  # A simple non UoW database session
  class Session
    include Adamantium::Flat

    # Read objects from database
    #
    # The container can use the passed block to load objects guarded by identity map.
    #
    # @example
    #   people = session.read(Person, :lastname => 'Doe')
    #
    # @param [Model] model
    #   the model to be queried
    #
    # @return [Object]
    #   the loaded objects wrapped by mapper defined query
    #
    # @api public
    #
    def read(model, query)
      mapper = @registry.resolve_model(model)
      Reader.new(self, mapper, query) 
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

      @tracker.delete(state)

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
      state = @tracker.get(object) do
        new_state(object)
      end

      @tracker.persist(state)

      self
    end

    # Returns whether an domain object is tracked in this session
    #
    # @example
    #   session.include?(Object.new) # => false
    #   person = session.first(Person)
    #   session.include?(person)     # => true
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
    def include?(object)
      @tracker.include?(object)
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
    # @return [true|false]
    #   returns true when there are changes in the object
    #   false otherwise
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

      @tracker.delete(state)

      self
    end

    # Load a domain object from dump and track it
    #
    # Will return already tracked object in case of identity map collision.
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
    def load(mapper, dump)
      state = State::Loading.new(mapper, dump)

      @tracker.load(state)
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
    # @raise [StateError] in case object is not tracked
    #
    # @return [State]
    #
    # @api private
    #
    def state(object)
      @tracker.get(object) do
        raise StateError, "#{object.inspect} is not tracked"
      end
    end

    # Initialize a State::New for domain object
    #
    # @param [Object] object
    #
    # @return [State::New]
    #
    # @api private
    #
    def new_state(object)
      mapper = @registry.resolve_object(object)
      State::New.new(Mapping.new(mapper, object))
    end
  end
end
