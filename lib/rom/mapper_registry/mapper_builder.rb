module ROM
  class MapperRegistry

    class MapperBuilder
      attr_reader :relation, :model_class, :attributes

      def initialize(relation)
        @relation = relation
      end

      def model(model_class, *attrs)
        domain_model = Class.new(Object) do
          attr_accessor *attrs

          def initialize(params)
            params.each do |name, value|
              send("#{name}=", value)
            end
          end
        end

        @model_class = Object.const_set(model_class, domain_model)
        @attributes = attrs.each_with_object({}) { |name, h| h[name] = { type: relation.header[name][:type] } }
      end

      def call
        header = Header.new(attributes)
        Mapper.new(relation, header, model_class)
      end

    end

  end
end
