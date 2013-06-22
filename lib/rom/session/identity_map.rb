module ROM
  class Session

    class IdentityMap
      LoadedObject = Struct.new(:object, :tuple)

      def initialize(tracker = {})
        @tracker = tracker
        @objects = {}
      end

      def [](identity)
        @objects[identity]
      end

      def fetch(identity, &block)
        @objects.fetch(identity, &block).object
      end

      def store(identity, object, tuple)
        @objects[identity] = LoadedObject.new(object, tuple)
        @tracker.store(object, State::Persisted.new(object))
        self
      end

    end # IdentityMap

  end # Session
end # ROM
