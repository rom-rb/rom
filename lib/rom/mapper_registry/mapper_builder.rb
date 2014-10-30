require 'rom/mapper_registry/model_builder'

module ROM
  class MapperRegistry

    class MapperBuilder
      attr_reader :name, :header, :root, :model_class, :attributes

      def initialize(name, header, root = nil)
        @name = name
        @header = header
        @root = root
        @attributes = header.dup
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

      def group(options)
        attributes.concat(options.keys)
      end

      def call
        if @model_opts
          builder = @builder_class.new(attributes, @modeL_opts)
          @model_class = builder.call
          Object.const_set(@const_name, model_class) if @const_name
        else
          @model_class = @root.model unless @model_class
        end

        header_attrs = attributes.map { |name| [name, Object] }
        header = Header.coerce(header_attrs)

        Mapper.new(header, model_class)
      end

    end

  end
end
