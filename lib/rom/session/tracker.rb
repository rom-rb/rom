# encoding: utf-8

module ROM
  class Session

    # @api private
    class Tracker
      attr_reader :objects, :changelog
      private :objects, :changelog

      # @api private
      def initialize
        @objects   = {}
        @changelog = []
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

      private

      # @api private
      def store(object, state)
        @objects[object.__id__] = state
      end

    end # Tracker

  end # Session
end # ROM
