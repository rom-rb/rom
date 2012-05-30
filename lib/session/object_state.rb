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

  protected

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

    # Create a derived object state with
    #
    # @param [Class<ObjectState>] class
    #   the class of the new object state
    #
    # @return [ObjectState]
    #   the new object state.
    #
    # @api private
    #
    def transition(klass)
      klass.new(@mapper,@object)
    end

    # An ObjectState that represents a new unpersisted domain object.
    class New < ObjectState

      # Insert via mapper and return loaded object state
      #
      # @return [ObjectState::Loaded]
      #
      # @api private
      #
      def insert
        @mapper.insert_dump(dump)

        transition(Loaded)
      end

      alias :persist :insert
    end

    # An ObjectState that represents a abandoned domain object. It is no longer state tracked.
    class Abandoned 
      # Return the wrapped domain object
      #
      # @return [Object]
      #
      # @api private
      #
      attr_reader :object

      # Initialized abandoned object state
      #
      # @param [Object] object the abandoned domain object
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
      def update_identity_map(identity_map)
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
      def clean?(dump=self.dump)
        @remote_dump == dump
      end

      # Invoke transition to abandoned object state
      #
      # @return [ObjectState::Abandoned]
      #
      # @api private
      #
      def abandon
        transition_to_abandoned
      end

      # Invoke transition to abandoned object state after deleting via mapper
      #
      # @return [ObjectState::Abandoned]
      #
      # @api private
      #
      def delete
        @mapper.delete(@remote_key)

        transition_to_abandoned
      end

      # Persist changes to wrapped domain object
      #
      # Noop when not dirty.
      #
      # @return [self]
      #
      # @api private
      #
      def update
        dump = self.dump

        unless clean?(dump)
          @mapper.update(@remote_key,dump,@remote_dump)
          store_remote
        end

        self
      end

      alias :persist :update

      # Insert domain object into identity map
      #
      # @param [Hash] identity map 
      #
      # @return [self]
      #
      # @api private
      #
      def update_identity_map(identity_map)
        identity_map[@remote_key]=@object

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

    protected

      # Return abandoned object state derived from this instance
      #
      # @return [ObjectState::Abandoned] 
      #
      # @api private
      #
      def transition_to_abandoned
        Abandoned.new(@object,@remote_key)
      end

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
