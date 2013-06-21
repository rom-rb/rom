module ROM
  class Session

    # TODO: consider using a decorator instead
    class Mapper < ROM::Mapper
      attr_reader :im

      def initialize(loader, dumper, im)
        super(loader, dumper)
        @im = im
      end

      def load(tuple)
        identity = loader.identity(tuple)
        im.fetch(identity) { im.store(identity, super, tuple)[identity] }
      end

    end # Mapper

  end # Session
end # ROM
