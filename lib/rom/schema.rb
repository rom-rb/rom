module ROM

  class Schema

    include Concord.new(:relations)
    include Adamantium

    def self.build(&block)
      new(Definition.relations(&block))
    end

    def [](name)
      relations[name]
    end

    class Definition

      class Relation

        class Base < self

          attr_reader :repository

          def repository(name)
            @repository = name
          end
        end

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

    end # class Definition
  end # class Schema
end # module ROM
