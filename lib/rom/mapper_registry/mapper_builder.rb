module ROM
  class MapperRegistry

    class MapperBuilder
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

  end
end
