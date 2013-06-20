require 'adamantium'
require 'equalizer'
require 'abstract_type'
require 'concord'

require 'rom-mapper'

module ROM

  # Session namespace
  module Session

    class Mapper < ROM::Mapper
      attr_reader :im
      private :im

      def initialize(loader, dumper, im)
        super(loader, dumper)
        @im = im
      end

      def load(tuple)
        identity = loader.identity(tuple)
        im.fetch(identity) { im[identity] = super }
      end

    end # Mapper

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
