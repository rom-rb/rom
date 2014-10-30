require 'rom/mapper_registry/model_builder'

module ROM
  class MapperRegistry

    class MapperBuilder
      attr_reader :name, :header, :root, :model_class, :attributes, :group

      def initialize(name, header, root = nil)
        @name = name
        @header = header
        @root = root
        @attributes = header
      end

      def model(options)
        name = options[:name]
        type = options.fetch(:type) { :poro }

        @attributes = options[:map] if options[:map]

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

      def group(options)
        @group = options
        attributes.concat([options])
      end

      def call
        @model_class = @root.model unless @model_class

        header_attrs = attributes.map { |name| [name, Object] }
        header = Header.coerce(header_attrs)

        Mapper.new(header, model_class)
      end

    end

  end
end
