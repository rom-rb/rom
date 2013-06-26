module ROM
  class Session

    class IdentityMap
      LoadedObject = Struct.new(:object, :tuple)

      class ObjectMissingError < StandardError
        def initialize(identity)
          super("An object with identity=#{identity.inspect} was not found in the identity map")
        end
      end

      def initialize
        @objects = {}
      end

      def [](identity)
        @objects.fetch(identity) { raise ObjectMissingError, identity }
      end

      def fetch(identity, &block)
        @objects.fetch(identity, &block).object
      end

      def fetch_tuple(identity)
        self[identity].tuple
      end

      def fetch_object(identity)
        self[identity].object
      end

      def store(identity, object, tuple)
        @objects[identity] = LoadedObject.new(object, tuple)
        self
      end

    end # IdentityMap

  end # Session
end # ROM
