module ROM
  class Session

    class Tracker
      attr_reader :objects, :changelog

      def initialize
        @identity_map = Hash.new { |hash, key| hash[key] = IdentityMap.new(self) }
        @objects      = Hash.new
        @changelog    = []
      end

      def [](object)
        @objects[object]
      end

      def fetch(object)
        @objects.fetch(object) {
          raise "tracker doesn't include #{object.inspect}"
        }
      end

      def include?(object)
        @objects.key?(object)
      end

      def queue(state)
        @changelog << state
        update(state)
      end

      def update(state)
        store(state.object, state)
      end

      def store(object, state)
        @objects[object] = state
      end

      def identity_map(relation_name)
        @identity_map[relation_name]
      end

    end # Tracker

  end # Session
end # ROM
