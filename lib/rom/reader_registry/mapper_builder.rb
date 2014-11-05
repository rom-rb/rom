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
        @attributes = root.header.zip
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
        attributes << [name]
      end

      def exclude(name)
        attributes.delete([name])
      end

      def group(options)
        options.each do |name, header|
          attributes << [name, header: header.zip, type: Array]
        end
      end

      def wrap(options)
        options.each do |name, header|
          attributes << [name, header: header.zip, type: Hash]
        end
      end

      def call
        header = Header.coerce(attributes)

        @model_class = model_builder.call(header) if model_builder

        mappers[name] = Mapper.new(header, model_class)
      end

    end

  end
end
