module ROM
  class Session

    # @api public
    class Environment < ROM::Environment
      include Proxy

      attr_reader :environment
      private :environment

      attr_reader :tracker
      private :tracker

      attr_reader :memory
      private :memory

      def initialize(environment, tracker)
        @environment = environment
        @tracker     = tracker
        initialize_memory
      end

      # @api public
      def [](name)
        memory[name]
      end

      # @api private
      def commit
        tracker.commit
      end

      private

      # @api private
      def initialize_memory
        @memory = Hash.new { |memory, name| memory[name] = build_relation(name) }
      end

      # @api private
      def build_relation(name)
        Session::Relation.build(environment[name], tracker, tracker.identity_map(name))
      end

    end # Registry

  end # Session
end # ROM
