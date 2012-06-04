module Session
  # An objects persistance state
  class ObjectState
    # Return wrapped domain object
    #
    # @return [Object]
    #
    # @api private
    #
    attr_reader :object

    # Return dumped representation of object 
    #
    # The dump is not cached.
    #
    # @return [Object] 
    #   the dumped representation
    #
    # @api private
    #
    def dump
      @mapper.dump(@object)
    end

    # Return dumped key representation of object
    #
    # The key is not cached.
    #
    # @return [Object] 
    #   the key 
    #
    # @api private
    #
    def key
      @mapper.dump_key(@object)
    end

    # Update track
    #
    # Noop default implementation for all states.
    #
    # @param [Object] track
    #
    # @return [self]
    #
    # @api private
    #
    def update_track(track)
      self
    end

    # Update identity map
    #
    # Noop default implementation for all states.
    #
    # @param [Object] identitymap
    #
    # @return [self]
    #
    # @api private
    #
    def update_identity(identity_map)
      self
    end

    # Empty identity map
    #
    # Noop default implementation for all states.
    #
    # @param [Object] identitymap
    #
    # @return [self]
    #
    # @api private
    #
    def delete_identity(identity_map)
      self
    end

    # Delete domain object
    #
    # Default implementation for all subclasses.
    #
    # @raise [StateError]
    #
    # @return [undefined]
    #
    # @api private
    #
    def delete
      raise StateError,"#{self.class.name} cannot be deleted"
    end

    # Forget domain object
    #
    # Default implementation for all subclasses.
    #
    # @raise [StateError]
    #
    # @return [undefined]
    #
    # @api private
    #
    def forget
      raise StateError,"#{self.class.name} cannot be forgotten"
    end

    # Persist domain object
    #
    # Default implementation for all subclasses.
    #
    # @raise [StateError]
    #
    # @return [undefined]
    #
    # @api private
    #
    def persist
      raise StateError,"#{self.class.name} cannot be persisted"
    end

  private

    # Initialize object state instance
    #
    # @param [Mapper] mapper the mapper for wrapped domain object
    # @param [Object] object the wrapped domain object
    #
    # @return [self]
    #
    # @api private
    #
    def initialize(mapper,object)
      @mapper,@object = mapper,object

      self
    end

    # An ObjectState that represents a new unpersisted domain object.
    class New < ObjectState
      # Insert via mapper and return loaded object state
      #
      # @return [ObjectState::Loaded]
      #
      # @api private
      #
      def persist
        @mapper.insert_dump(dump)

        Loaded.new(@mapper,@object)
      end
    end

    # An ObjectState that represents a forgotten domain object. It is no longer state tracked.
    class Forgotten < ObjectState
      # Initialized forgotten object state
      #
      # @param [Object] object the forgotten domain object
      # @param [Object] remote_key the last remote key
      #
      # @api private
      #
      def initialize(object,remote_key)
        @object,@remote_key = object,remote_key
      end

      # Remove object from identity map
      #
      # @param [Hash] identity_map 
      #
      # @return [self]
      #
      # @api private
      #
      def update_identity(identity_map)
        identity_map.delete(@remote_key)

        self
      end

      # Remove object from tracking 
      #
      # @param [Hash] track 
      #
      # @return [self]
      #
      # @api private
      #
      def update_track(track)
        track.delete(@object)

        self
      end
    end

    # An ObjectState that represents a loaded domain object.
    class Loaded < ObjectState
      # Return remote key
      #
      # @return [Object]
      #
      # @api private
      #
      attr_reader :remote_key

      # Initialize loaded object state
      #
      # @see Session::ObjectState#new
      #
      # @api private
      #
      def initialize(*)
        super
        store_remote
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
      # @return [ObjectState::Forgotten]
      #
      # @api private
      #
      def forget
        Forgotten.new(@object,@remote_key)
      end

      # Invoke transition to forgotten object state after deleting via mapper
      #
      # @return [ObjectState::Forgotten]
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
          @mapper.update(@remote_key,dump,@remote_dump)
          store_remote
        end

        self
      end

      # Insert domain object into identity map
      #
      # @param [Hash] identity map 
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
      # @param [Hash] identity map
      #
      # @return [ſelf]
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
      # @param [Object] object
      #
      # @return [ObjectState::Loader]
      #
      # @api private
      #
      def self.build(mapper,dump)
        object = mapper.load(dump)
        # TODO: pass dump to mapper to avoid dump => load => dump (#store_dump)
        new(mapper,object)
      end

    private

      # Store the current remote representation in this instance for later comparison
      #
      # @return [ſelf]
      #
      # @api private
      #
      def store_remote
        @remote_key,@remote_dump = key,dump

        self
      end
    end
  end
end
