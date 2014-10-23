require 'inflecto'

module ROM
  class RelationRegistry

    class RelationBuilder
      attr_reader :name, :relation, :schema

      def initialize(name, schema)
        @name = name
        @relation = schema[name]
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

        klass_name = "#{Relation.name}[#{Inflecto.camelize(name)}]"

        klass = Class.new(Relation) { include(mod) }

        klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.name
            #{klass_name.inspect}
          end

          def inspect
            "#<#{klass_name} header=#\{header.inspect\} dataset=#\{dataset.inspect\}>"
          end
        RUBY

        klass.new(relation.dataset, relation.header)
      end
    end

  end

end
