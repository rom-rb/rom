module ROM
  class Session

    # @api private
    class Tracker
      attr_reader :objects, :changelog
      private :objects, :changelog

      class ObjectNotTrackedError < StandardError
        def initialize(object)
          super("Tracker doesn't include #{object.inspect}")
        end
      end

      # @api private
      def initialize
        @identity_map = Hash.new { |hash, key| hash[key] = IdentityMap.build }
        @objects      = Hash.new
        @changelog    = []
      end

      # @api private
      def commit
        @changelog.each { |state| update(state.commit) }
        @changelog = []
      end

      # @api private
      def fetch(object)
        @objects.fetch(object.__id__) { raise ObjectNotTrackedError, object }
      end

      # @api private
      def include?(object)
        @objects.key?(object.__id__)
      end

      # @api private
      def clean?
        changelog.empty?
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
      def store_transient(object, mapper)
        store(object, State::Transient.new(object, mapper))
      end

      # @api private
      def store_persisted(object, mapper)
        store(object, State::Persisted.new(object, mapper))
      end

      # @api private
      def identity_map(relation_name)
        @identity_map[relation_name]
      end

      private

      # @api private
      def store(object, state)
        @objects[object.__id__] = state
      end

    end # Tracker

  end # Session
end # ROM
