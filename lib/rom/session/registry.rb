module ROM
  class Session

    class Registry
      attr_reader :tracker
      private :tracker

      attr_reader :memory
      private :memory

      def initialize(tracker)
        @tracker = tracker
        @memory  = {}
      end

      def relations
        tracker.relations
      end

      def [](name)
        memory.fetch(name) { build_relation(name) }
      end

      def build_relation(name)
        memory[name] = Session::Relation.build(relations[name], tracker, tracker.identity_map(name))
      end

    end # Registry

  end # Session
end # ROM
