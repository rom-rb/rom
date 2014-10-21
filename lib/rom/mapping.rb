module ROM

  class Mapping
    class DSL
      attr_reader :relations, :mappers

      def initialize(relations)
        @relations = relations
        @mappers = {}
      end

      class RelationBuilder
        attr_reader :relation, :model_class, :attributes

        def initialize(relation)
          @relation = relation
        end

        def model(model_class)
          @model_class = model_class
        end

        def map(*names)
          @attributes = names.each_with_object({}) { |name, h| h[name] = { type: relation.header[name][:type] } }
        end

        def call
          header = Header.new(attributes)
          Mapper.new(relation, header, model_class)
        end
      end

      def relation(name, &block)
        builder = RelationBuilder.new(relations[name])
        builder.instance_exec(&block)
        @mappers[name] = builder.call
      end

      def call
        Mapping.new(@mappers)
      end

    end

    include Concord.new(:mappers)

    def self.define(relations, &block)
      dsl = DSL.new(relations)
      dsl.instance_exec(&block)
      dsl.call
    end

    def respond_to_missing?(name, include_private = false)
      mappers.key?(name)
    end

    def method_missing(name)
      mappers.fetch(name)
    end

  end

end
