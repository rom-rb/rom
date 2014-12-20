module ROM
  class Boot
    class RelationDSL
      attr_reader :schema, :relations

      def initialize(schema, relations)
        @schema = schema
        @relations = relations
      end

      def register(name, &block)
        relations[name] = [block]
      end

      def call
        relations
      end
    end
  end
end
