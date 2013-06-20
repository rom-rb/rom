module ROM
  class Session

    # TODO: consider using a decorator instead
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

  end # Session
end # ROM
