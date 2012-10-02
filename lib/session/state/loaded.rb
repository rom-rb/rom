module Session
  # An objects persistance state
  class State
    # An State that represents a loaded domain object.
    class Loaded < State
      # Initialize loaded object state
      #
      # @param [Object] mapper
      # @param [Object] object
      # @param [Object] remote_dump
      # @param [Object] remote_key
      #
      # @see Session::State#new
      #
      # @api private
      #
      def initialize(mapper, object, remote_dump=Undefined, remote_key=Undefined)
        super(mapper, object)
        @remote_dump = remote_dump == Undefined ? dump : remote_dump
        @remote_key  = remote_key  == Undefined ? key  : remote_key
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
      def dirty?(dump=self.dump)
        @remote_dump != dump
      end

      # Invoke transition to forgotten object state
      #
      # @return [State::Forgotten]
      #
      # @api private
      #
      def forget
        Forgotten.new(@object, @remote_key)
      end

      # Invoke transition to forgotten object state after deleting via mapper
      #
      # @return [State::Forgotten]
      #
      # @api private
      #
      def delete
        @mapper.delete(@remote_key)

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
        dump = self.dump

        if dirty?(dump)
          @mapper.update(@remote_key, dump, @remote_dump)
          return self.class.new(@mapper, @object, dump)
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
        identity_map[@remote_key]=@object

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
        identity_map.delete(@remote_key)

        self
      end

      # Insert object state into tracking
      #
      # @param [Hash] track the tracking object state will be inserted in.
      #
      # @return [self]
      #
      # @api private
      #
      def update_track(track)
        track[object]=self

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
