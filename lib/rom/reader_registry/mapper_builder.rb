require 'rom/reader_registry/model_builder'

module ROM
  class ReaderRegistry

    class MapperBuilder

      class AttributeDSL
        attr_reader :attributes

        def initialize
          @attributes = []
        end

        def header
          Header.coerce(attributes)
        end

        def attribute(name, options)
          attributes << [name, options]
        end
      end

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

      def attribute(name, options)
        attributes << [name, options]
      end

      def exclude(name)
        attributes.delete([name])
      end

      def group(options, &block)
        if block
          dsl = AttributeDSL.new
          dsl.instance_exec(&block)

          attributes << [options, header: dsl.header, type: Array]
        else
          options.each do |name, header|
            attributes << [name, header: header.zip, type: Array]
          end
        end
      end

      def wrap(options, &block)
        if block
          dsl = AttributeDSL.new
          dsl.instance_exec(&block)

          attributes << [options, header: dsl.header, type: Hash]
        else
          options.each do |name, header|
            attributes << [name, header: header.zip, type: Hash]
          end
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
