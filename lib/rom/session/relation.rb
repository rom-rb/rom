module ROM
  class Session

    # Adds session-specific functionality on top of ROM's relation.
    #
    # A session relation builds a queue of state changes that will be committed
    # when a session is flushed.
    #
    # @api public
    class Relation < ROM::Relation
      include Proxy

      attr_reader :relation, :tracker
      private :relation, :tracker

      # @api private
      def self.build(relation, tracker, identity_map)
        mapper = Session::Mapper.new(relation.mapper, identity_map)
        new(relation.inject_mapper(mapper), tracker)
      end

      # @api private
      def initialize(relation, tracker)
        @relation, @tracker = relation, tracker
      end

      # Transition an object into a saved state
      #
      # Transient object's state turns into Created
      # Persisted object's state turns into Updated
      #
      # @param [Object] an object to be saved
      #
      # @return [Session::Relation]
      #
      # @api public
      def save(object)
        # TODO: should we raise if object isn't transient or dirty?
        if state(object).transient? || dirty?(object)
          tracker.queue(state(object).save(relation))
        end
        self
      end

      # Transient an object into a deleted state
      #
      # @param [Object] an object to be deleted
      #
      # @return [Session::Relation]
      #
      # @api public
      def delete(object)
        tracker.queue(state(object).delete(relation))
        self
      end

      # Return current state of the tracked object
      #
      # @param [Object] an object
      #
      # @return [Session::State]
      #
      # @api public
      def state(object)
        tracker.fetch(object)
      end

      # Return object's identity
      #
      # @param [Object] an object
      #
      # @return [Array]
      #
      # @api public
      def identity(object)
        mapper.identity(object)
      end

      # Start tracking an object within this session
      #
      # @param [Object] an object to be track
      #
      # @return [Session::Relation]
      #
      # @api public
      def track(object)
        tracker.store(object, State::Transient.new(object))
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
      # @param [Object] an object
      #
      # @return [Boolean]
      #
      # @api public
      def dirty?(object)
        mapper.dirty?(object)
      end

      # Check if an object is being tracked
      #
      # @param [Object]
      #
      # @return [Boolean]
      #
      # @api public
      def tracking?(object)
        tracker.include?(object)
      end

    end # Relation

  end # Session
end # ROM
