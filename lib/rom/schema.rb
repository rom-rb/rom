module ROM

  class Schema

    include Concord.new(:relations)
    include Adamantium

    def self.build(&block)
      new(Definition.new(&block).relations)
    end

    def [](name)
      relations[name]
    end

    class Definition

      class Relation

        include Equalizer.new(:header, :keys)

        def initialize(&block)
          @header = []
          @keys   = []
          instance_eval(&block) if block
        end

        def header
          Axiom::Relation::Header.coerce(@header, :keys => @keys)
        end

        def attribute(name, type)
          @header << [name, type]
          self
        end

        def key(*attribute_names)
          @keys << attribute_names
          self
        end

      end # class Relation

      include Equalizer.new(:relations)

      attr_reader :relations

      def initialize(&block)
        @relations = {}
        instance_eval(&block) if block
      end

      def base_relation(name, &block)
        relation = Relation.new(&block)
        relations[name] = Axiom::Relation::Base.new(name, relation.header)
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

    end # class Definition
  end # class Schema
end # module ROM
