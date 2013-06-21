module ROM
  class Session

    class Relation < ROM::Relation
      include Concord.new(:relation, :tracker)

      DECORATED_CLASS = superclass
      undef_method *DECORATED_CLASS.public_instance_methods(false).map(&:to_s)

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
        tracker.queue(state(object).delete)
        self
      end

      def save(object)
        tracker.queue(state(object).save)
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

      private

      def method_missing(method, *args, &block)
        forwardable?(method) ? forward(method, *args, &block) : super
      end

      def forwardable?(method)
        relation.respond_to?(method)
      end

      def forward(*args, &block)
        response = relation.public_send(*args, &block)

        if response.equal?(relation)
          self
        elsif response.kind_of?(DECORATED_CLASS)
          self.class.new(response, tracker)
        else
          response
        end
      end

    end # Relation

  end # Session
end # ROM
