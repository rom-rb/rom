module ROM
  class MapperRegistry

    class MapperBuilder
      attr_reader :name, :relation, :model_class, :attributes

      def initialize(name, relation)
        @name = name
        @relation = relation
      end

      # TODO tweak this to support different model builders and make it use
      #      relation header by default with ability to override using options
      def model(model_class, *attrs)
        @attributes = *attrs

        domain_model = Class.new(Object) do
          attr_accessor *attrs

          def initialize(params)
            params.each do |name, value|
              send("#{name}=", value)
            end
          end
        end

        @model_class = Object.const_set(model_class, domain_model)
      end

      def call
        header_attrs = attributes.each_with_object({}) do |name, h|
          h[name] =
            # TODO add different attribute types to header so that we can set
            #      correct type if it's a grouped or wrapped relation
            if relation.header.key?(name)
              { type: relation.header[name][:type] }
            else
              {}
            end
        end

        header = Header.new(header_attrs)

        Mapper.new(header, model_class)
      end

    end

  end
end
