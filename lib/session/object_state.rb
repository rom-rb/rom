module Session
  # An objects persistance state
  class ObjectState
    # Mabe use Virtus::ValueObject to get equalizer on @object and @mapper for free?
    attr_reader :object

    # Return dumped representation of object. The dump is not cached.
    #
    # @return [Object] the dumped representation
    #
    def dump
      @mapper.dump(@object)
    end

  protected

    def initialize(mapper,object)
      @mapper,@object = mapper,object
    end

    # Create a new object state with klass.
    #
    # @param [Class] class of the new object state
    #
    # @return The new object state.
    #
    def transition(klass)
      klass.new(@mapper,@object)
    end

    # An ObjectState that represents a new unpersisted domain object.
    class New < ObjectState
      def insert
        @mapper.insert_dump(dump)

        transition(Loaded)
      end
    end

    # An ObjectState that represents a loaded domain object.
    class Loaded < ObjectState
      attr_reader :remote_key

      def initialize(*)
        super
        store_remote
      end

      def clean?(dump=self.dump)
        @remote_dump == dump
      end

      def delete
        @mapper.delete(@remote_key)

        nil
      end

      def update
        dump = self.dump

        unless clean?(dump)
          @mapper.update(@remote_key,dump,@remote_dump)
          store_remote
        end

        self
      end

    protected

      def store_remote
        @remote_key = @mapper.dump_key(@object)
        @remote_dump = @mapper.dump(@object)

        self
      end
    end
  end
end
