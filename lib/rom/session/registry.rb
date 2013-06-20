module ROM
  class Session

    class Registry
      attr_reader :relations
      private :relations

      attr_reader :im
      private :im

      attr_reader :memory
      private :memory

      def initialize(relations, im)
        @relations, @im = relations, im
        @memory = {}
      end

      def [](name)
        memory.fetch(name) { build_relation(name) }
      end

      def build_relation(name)
        relation = relations[name]
        loader   = relation.mapper.loader
        dumper   = relation.mapper.dumper
        mapper   = Session::Mapper.new(loader, dumper, im)

        memory[name] = relation.inject_mapper(mapper)
      end

    end # Registry

  end # Session
end # ROM
