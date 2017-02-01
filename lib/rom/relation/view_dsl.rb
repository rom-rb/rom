module ROM
  class Relation
    class ViewDSL
      attr_reader :name

      attr_reader :relation_block

      attr_reader :new_schema

      def initialize(name, schema, &block)
        @name = name
        @schema = schema
        @new_schema = nil
        @relation_block = nil
        instance_eval(&block)
      end

      def schema(&block)
        @new_schema = -> relations { @schema.with(relations: relations).instance_exec(&block) }
      end

      def relation(&block)
        @relation_block = lambda(&block)
      end

      def call
        [name, new_schema, relation_block]
      end
    end
  end
end
