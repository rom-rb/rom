module ROM
  class Session

    class Registry
      include Concord.new(:relations, :im)

      attr_reader :memory
      private :memory

      def memory
        @memory ||= {}
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
