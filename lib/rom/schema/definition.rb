module ROM
  class Schema

    class Definition
      include Equalizer.new(:relations)

      attr_reader :relations
      attr_reader :repositories

      def initialize(&block)
        @relations    = {}
        @repositories = {}
        instance_eval(&block) if block
      end

      def base_relation(name, &block)
        base            = Relation::Base.new(&block)
        relation        = Axiom::Relation::Base.new(name, base.header)
        relations[name] = relation

        (repositories[base.repository] ||= []) << relation

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
