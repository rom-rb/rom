module Session
  class State
    # An State that represents a loaded domain object.
    class Loaded < self
      # Initialize loaded object state
      #
      # @param [Object] mapper
      # @param [Object] object
      #
      # @see Session::State#new
      #
      # @api private
      #
      def initialize(mapper, object)
        super(mapper, object)
      end

      # Returns whether wrapped domain object is dirty
      #
      # If no dump is provided as argument domain object will be dumped.
      #
      # @param [Object] dump the dump to indicate dirtiness against
      #
      # @return [true|false]
      #
      # @api private
      #
      def dirty?
        dump != @mapper.dump(@object)
      end

      # Invoke transition to forgotten object state
      #
      # @return [State::Forgotten]
      #
      # @api private
      #
      def forget
        Forgotten.new(@object, key)
      end

      # Invoke transition to forgotten object state after deleting via mapper
      #
      # @return [State::Forgotten]
      #
      # @api private
      #
      def delete
        @mapper.delete(key)

        forget
      end

      # Persist changes to wrapped domain object
      #
      # Noop when not dirty.
      #
      # @return [self]
      #
      # @api private
      #
      def persist
        if dirty?
          new_dump = @mapper.dump(@object)
          new_key  = @mapper.dump_key(@object)

          @mapper.update(key, new_dump, dump)

          return self.class.new(@mapper, @object)
        end

        self
      end

      # Insert domain object into identity map
      #
      # @param [Hash] identity_map
      #
      # @return [self]
      #
      # @api private
      #
      def update_identity(identity_map)
        identity_map[key]=@object

        self
      end

      # Delete object from identity map
      #
      # @param [Hash] identity_map
      #
      # @return [self]
      #
      # @api private
      #
      def delete_identity(identity_map)
        identity_map.delete(key)

        self
      end

      # Insert object state into tracking
      #
      # @param [Tracker] tracker
      #
      # @return [self]
      #
      # @api private
      #
      def update_tracker(tracker)
        tracker.store(object, self)

        self
      end

      # Build object state from mapper and dump
      #
      # @param [Mapper] mapper
      #   the mapper used to build domain object
      #
      # @param [Object] dump
      #
      # @return [State::Loader]
      #
      # @api private
      #
      def self.build(mapper, dump)
        object = mapper.load(dump)
        # TODO: pass dump to mapper to avoid dump => load => dump (#store_dump)
        new(mapper, object)
      end
    end
  end
end
