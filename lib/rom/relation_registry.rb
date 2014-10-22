module ROM

  class RelationRegistry

    class DSL

      class RelationBuilder
        attr_reader :relation, :schema

        def initialize(relation, schema)
          @relation = relation
          @schema = schema
        end

        def call(&block)
          relations = schema.relations

          mod = Module.new
          mod.module_exec(&block)

          mod.module_exec do
            relations.each do |name, relation|
              define_method(name) { relation.dataset }
            end
          end

          Class.new(Relation).send(:include, mod).new(relation)
        end
      end

      attr_reader :schema, :mappers, :relations

      def initialize(schema, mappers)
        @schema = schema
        @mappers = mappers
        @relations = {}
      end

      def call
        RelationRegistry.new(relations, mappers)
      end

      def method_missing(name, *args, &block)
        builder = RelationBuilder.new(schema[name], schema)
        relation = builder.call(&block)

        relations[name] = relation
      end
    end

    include Concord.new(:relations, :mappers)

    def self.define(schema, mappers, &block)
      dsl = DSL.new(schema, mappers)
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

    def method_missing(name, *args)
      options = args.first || {}
      relation = relations[name]

      if options[:mapper]
        mappers[name].new(relation)
      else
        relation
      end
    end

  end
end
