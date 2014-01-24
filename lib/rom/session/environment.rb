# encoding: utf-8

module ROM
  class Session

    # Session-specific environment wrapping ROM's environment
    #
    # It works exactly the same as ROM::Environment except it returns
    # session relations
    #
    # @api public
    class Environment
      include Charlatan.new(:environment)

      attr_reader :environment, :tracker, :memory
      private :environment, :tracker, :memory

      # @api private
      def self.build(environment, tracker = Tracker.new)
        new(environment, tracker)
      end

      # @api private
      def initialize(environment, tracker)
        super
        @environment = environment
        @tracker     = tracker
        initialize_memory
      end

      # Return a relation identified by name
      #
      # @param [Symbol] name of a relation
      #
      # @return [Session::Relation] rom's relation wrapped by session
      #
      # @api public
      def [](name)
        memory[name]
      end

      # @api private
      def commit
        tracker.commit
      end

      # @api private
      def clean?
        tracker.clean?
      end

      private

      # @api private
      def initialize_memory
        @memory = Hash.new { |_, name| memory[name] = build_relation(name) }
      end

      # @api private
      def build_relation(name)
        Relation.build(environment[name], tracker)
      end

    end # Environment

  end # Session
end # ROM
