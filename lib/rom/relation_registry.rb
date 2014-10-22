module ROM

  class RelationRegistry

    class DSL

      class RelationBuilder
        attr_reader :relation

        def initialize(relation)
          @relation = relation
        end

        def call(&block)
          mod = Module.new
          mod.module_exec(&block)

          Class.new(Relation).send(:include, mod).new(relation)
        end
      end

      attr_reader :schema, :relations

      def initialize(schema)
        @schema = schema
        @relations = {}
      end

      def call
        RelationRegistry.new(relations)
      end

      def method_missing(name, *args, &block)
        builder = RelationBuilder.new(schema[name])
        relation = builder.call(&block)

        relations[name] = relation
      end
    end

    include Concord.new(:relations)

    def self.define(relations, &block)
      dsl = DSL.new(relations)
      dsl.instance_exec(&block)
      dsl.call
    end

    def [](name)
      relations.fetch(name)
    end

    def respond_to_missing?(name, include_private = false)
      relations.key?(name)
    end

    private

    def method_missing(name)
      relations[name]
    end

  end
end
