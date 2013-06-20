module ROM
  class Session

    class Registry
      attr_reader :relations
      private :relations

      attr_reader :tracker
      private :tracker

      attr_reader :memory
      private :memory

      def initialize(relations, tracker)
        @relations, @tracker = relations, tracker
        @memory = {}
      end

      def [](name)
        memory.fetch(name) { build_relation(name) }
      end

      def build_relation(name)
        relation = relations[name]
        loader   = relation.mapper.loader
        dumper   = relation.mapper.dumper
        mapper   = Session::Mapper.new(loader, dumper, tracker.fetch(name))

        memory[name] = relation.inject_mapper(mapper)
      end

    end # Registry

  end # Session
end # ROM
