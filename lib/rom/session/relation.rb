# encoding: utf-8

module ROM
  class Session

    # Adds session-specific functionality on top of ROM's relation.
    #
    # A session relation builds a queue of state changes that will be committed
    # when a session is flushed.
    #
    # @api public
    class Relation
      include Charlatan.new(:relation, kind: ROM::Relation)

      attr_reader :tracker, :identity_map

      # Session reader uses identity map to fetch already loaded objects
      #
      # @api private
      class SessionReader
        include Concord.new(:identity_map)

        attr_reader :on_loaded

        # @api private
        def initialize(*args, &block)
          super
          @on_loaded = block
        end

        # @api private
        def call(tuples, mapper)
          tuples.each do |tuple|
            identity = mapper.identity_from_tuple(tuple)

            yield identity_map.fetch_object(identity) {
              on_loaded.call(identity, mapper.load(tuple), tuple)
            }
          end
        end

      end

      # @api private
      def self.build(relation, tracker)
        new(relation, tracker, IdentityMap.build)
      end

      # @api private
      def initialize(relation, tracker, identity_map)
        reader = SessionReader.new(identity_map, &method(:on_loaded))

        @relation = relation.inject_reader(reader)
        @tracker = tracker
        @identity_map = identity_map

        super(@relation, tracker, identity_map)
      end

      # @see ROM::Relation#insert
      #
      # @api public
      def insert!(object)
        identity_map.store(identity(object), object, mapper.dump(object))
        __new__(relation.insert(object))
      end

      # @see ROM::Relation#update
      #
      # @api public
      def update!(object, original_tuple)
        __new__(relation.update(object, original_tuple))
      end

      # @see ROM::Relation#delete
      #
      # @api public
      def delete!(object)
        __new__(relation.delete(object))
      end

      # Transition an object into a saved state
      #
      # Transient object's state turns into Created
      # Persisted object's state turns into Updated
      #
      # @param [Object] object an object to be saved
      #
      # @return [Session::Relation]
      #
      # @api public
      def save(object)
        tracker.queue(state(object).save)
        self
      end

      # Queue an object to be updated
      #
      # @param [Object] object object to be updated
      # @param [Hash] tuple new attributes for the update
      #
      # @return [self]
      #
      # @api public
      def update_attributes(object, tuple)
        tracker.queue(state(object).update(tuple))
        self
      end

      # Transient an object into a deleted state
      #
      # @param [Object] object an object to be deleted
      #
      # @return [Session::Relation]
      #
      # @api public
      def delete(object)
        tracker.queue(state(object).delete)
        self
      end

      # Return current state of the tracked object
      #
      # @param [Object] object an object
      #
      # @return [Session::State]
      #
      # @api public
      def state(object)
        tracker.fetch(identity(object))
      end

      # Return object's identity
      #
      # @param [Object] object an object
      #
      # @return [Array]
      #
      # @api public
      def identity(object)
        keys = mapper.identity(object)

        if keys.empty?
          object.__id__
        else
          keys
        end
      end

      # Start tracking an object within this session
      #
      # @param [Object] object an object to be tracked
      #
      # @return [Session::Relation]
      #
      # @api public
      def track(object)
        tracker.store_transient(object, self)
        self
      end

      # Build a new object instance and start tracking
      #
      # @return [Object]
      #
      # @api public
      def new(*args, &block)
        object = mapper.new_object(*args, &block)
        track(object)
        object
      end

      # Check if a tracked object is dirty
      #
      # @param [Object] object an object
      #
      # @return [Boolean]
      #
      # @api public
      def dirty?(object)
        state(object).transient? || identity_map.fetch_tuple(identity(object)) != mapper.dump(object)
      end

      # Check if an object is being tracked
      #
      # @param [Object] object an object
      #
      # @return [Boolean]
      #
      # @api public
      def tracking?(object)
        tracker.include?(identity(object))
      end

      private

      # @api private
      def __new__(new_relation)
        self.class.new(new_relation, tracker, identity_map)
      end

      # @api private
      def on_loaded(identity, object, tuple)
        tracker.store_persisted(object, self)
        identity_map.store(identity, object, tuple)[identity]
      end

    end # Relation

  end # Session
end # ROM
