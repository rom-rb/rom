require 'rom/mapper_registry/model_builder'

module ROM
  class MapperRegistry

    class MapperBuilder
      attr_reader :name, :relation, :model_class, :attributes

      def initialize(name, relation)
        @name = name
        @relation = relation
      end

      def model(options)
        name = options[:name]
        type = options.fetch(:type) { :poro }

        @attributes = options.fetch(:map) { relation.header.attributes.keys }

        builder_class =
          case type
          when :poro then ModelBuilder::PORO
          else
            raise ArgumentError, "#{type.inspect} is not a supported model type"
          end

        builder = builder_class.new(attributes, options)

        @model_class = builder.call

        Object.const_set(name, @model_class) if name

        @model_class
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
