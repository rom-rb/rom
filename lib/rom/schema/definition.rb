module ROM
  class Schema

    class Definition
      include Equalizer.new(:relations)

      def self.relations(&block)
        new(&block).relations
      end

      attr_reader :relations

      def initialize(&block)
        @relations = {}
        instance_eval(&block) if block
      end

      def base_relation(name, &block)
        header = Relation::Base.new(&block).header
        relations[name] = Axiom::Relation::Base.new(name, header)
        self
      end

      def relation(name, &block)
        relations[name] = instance_eval(&block)
        self
      end

      def [](name)
        relations[name]
      end

      def method_missing(name, *args, &block)
        return super unless relations.key?(name)
        relations[name]
      end

      def respond_to?(name)
        super || relations.key?(name)
      end

    end # Definition

  end # Schema
end # ROM
