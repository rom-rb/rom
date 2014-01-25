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
      def fetch(identity)
        @objects.fetch(identity) { raise ObjectNotTrackedError, identity }
      end

      # @api private
      def include?(identity)
        @objects.key?(identity)
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
        @objects[state.identity] = state
      end

      # @api private
      def store_transient(object, mapper)
        update(State::Transient.new(object, mapper))
      end

      # @api private
      def store_persisted(object, mapper)
        update(State::Persisted.new(object, mapper))
      end

    end # Tracker

  end # Session
end # ROM
