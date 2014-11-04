require 'rom/reader_registry/model_builder'

module ROM
  class ReaderRegistry

    class MapperBuilder
      attr_reader :name, :root, :mappers,
        :model_builder, :model_class, :attributes

      def initialize(name, root, mappers)
        @name = name
        @root = root
        @mappers = mappers
        @attributes = root.header.dup
        @model_class = mappers[root.name].model if mappers[root.name]
      end

      def model(options)
        if options.is_a?(Class)
          @model_class = options
        else
          @model_builder = ModelBuilder[options.fetch(:type) { :poro }].new(options)
        end

        self
      end

      def attribute(name)
        attributes << name
      end

      def exclude(name)
        attributes.delete(name)
      end

      def group(options)
        attributes.concat(options.keys)
      end

      def call
        @model_class = model_builder.call(attributes) if model_builder

        header_attrs = attributes.map { |name| [name, Object] }
        header = Header.coerce(header_attrs)

        mappers[name] = Mapper.new(header, model_class)
      end

    end

  end
end
