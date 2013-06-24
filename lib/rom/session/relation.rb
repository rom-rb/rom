module ROM
  class Session

    class Relation < ROM::Relation
      include Proxy

      attr_reader :relation, :tracker
      public :relation, :tracker

      def initialize(relation, tracker)
        @relation, @tracker = relation, tracker
      end

      def self.build(relation, tracker, identity_map)
        loader = relation.mapper.loader
        dumper = relation.mapper.dumper
        mapper = Session::Mapper.new(loader, dumper, identity_map)

        new(relation.inject_mapper(mapper), tracker)
      end

      def identity(object)
        dumper.identity(object)
      end

      def state(object)
        tracker.fetch(object)
      end

      def track(object)
        tracker.store(object, State::Transient.new(object))
        self
      end

      def delete(object)
        tracker.queue(state(object).delete(relation))
        self
      end

      def save(object)
        # TODO: should we raise if object isn't transient or dirty?
        if state(object).transient? || dirty?(object)
          tracker.queue(state(object).save(relation))
        end
        self
      end

      def dirty?(object)
        mapper.im[identity(object)].tuple != dumper.call(object)
      end

      def tracking?(object)
        tracker.include?(object)
      end

      def mapper
        relation.mapper
      end

      def loader
        mapper.loader
      end

      def dumper
        mapper.dumper
      end

    end # Relation

  end # Session
end # ROM
