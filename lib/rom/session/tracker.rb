module ROM
  class Session

    class Tracker
      attr_reader :objects, :changelog

      def initialize
        @identity_map = Hash.new { |hash, key| hash[key] = IdentityMap.new(self) }
        @objects      = Hash.new
        @changelog    = []
      end

      def commit
        @changelog.each { |state| update(state.commit) }
        @changelog = []
        self
      end

      def [](object)
        @objects[object.object_id]
      end

      def fetch(object)
        @objects.fetch(object.object_id) {
          raise "tracker doesn't include #{object.inspect}"
        }
      end

      def include?(object)
        @objects.key?(object.object_id)
      end

      def queue(state)
        @changelog << state
        update(state)
      end

      def update(state)
        store(state.object, state)
      end

      def store(object, state)
        @objects[object.object_id] = state
      end

      def identity_map(relation_name)
        @identity_map[relation_name]
      end

    end # Tracker

  end # Session
end # ROM
