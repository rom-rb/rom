module ROM
  class Session

    class Registry
      attr_reader :environment
      private :environment

      attr_reader :tracker
      private :tracker

      attr_reader :memory
      private :memory

      def initialize(environment, tracker)
        @environment = environment
        @tracker     = tracker
        @memory      = {}
      end

      def [](name)
        memory.fetch(name) { build_relation(name) }
      end

      def build_relation(name)
        memory[name] = Session::Relation.build(environment[name], tracker, tracker.identity_map(name))
      end

    end # Registry

  end # Session
end # ROM
