module ROM
  class Session

    # @api private
    class Tracker
      attr_reader :objects, :changelog
      private :objects, :changelog

      # @api private
      def initialize
        @identity_map = Hash.new { |hash, key| hash[key] = IdentityMap.new(self) }
        @objects      = Hash.new
        @changelog    = []
      end

      # @api private
      def commit
        @changelog.each { |state| update(state.commit) }
        @changelog = []
        self
      end

      # @api private
      def fetch(object)
        @objects.fetch(object.object_id) {
          raise "tracker doesn't include #{object.inspect}"
        }
      end

      # @api private
      def include?(object)
        @objects.key?(object.object_id)
      end

      # @api private
      def queue(state)
        @changelog << state
        update(state)
      end

      # @api private
      def update(state)
        store(state.object, state)
      end

      # @api private
      def store(object, state)
        @objects[object.object_id] = state
      end

      # @api private
      def identity_map(relation_name)
        @identity_map[relation_name]
      end

    end # Tracker

  end # Session
end # ROM
