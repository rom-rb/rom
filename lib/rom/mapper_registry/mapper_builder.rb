require 'rom/mapper_registry/model_builder'

module ROM
  class MapperRegistry

    class MapperBuilder
      attr_reader :name, :root, :mappers,
        :builder_class, :model_class, :attributes

      def initialize(name, root, mappers)
        @name = name
        @root = root
        @mappers = mappers
        @attributes = root.header.dup
      end

      def model(options)
        if options.is_a?(Class)
          @model_class = options
        else
          @model_opts = options
          @const_name = options[:name]
          @attributes = options[:map] if options[:map]

          type = options.fetch(:type) { :poro }

          @builder_class =
            case type
            when :poro then ModelBuilder::PORO
            else
              raise ArgumentError, "#{type.inspect} is not a supported model type"
            end
          self
        end
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
        if builder_class
          builder = builder_class.new(attributes, @model_opts)
          @model_class = builder.call
          Object.const_set(@const_name, model_class) if @const_name
        elsif !model_class
          @model_class = mappers[root.name].model
        end

        header_attrs = attributes.map { |name| [name, Object] }
        header = Header.coerce(header_attrs)

        mappers[name] = Mapper.new(header, model_class)
      end

    end

  end
end
