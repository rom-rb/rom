require 'rom/model_builder'

module ROM

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

    attr_reader :name, :root, :prefix,
      :model_builder, :model_class, :attributes

    def initialize(name, root, options = {})
      @name = name
      @root = root
      @prefix = options[:prefix]
      @attributes = root.header.map { |attr| [prefix ? :"#{prefix}_#{attr}" : attr] }
    end

    def model(options)
      if options.is_a?(Class)
        @model_class = options
      else
        @model_builder = ModelBuilder[options.fetch(:type) { :poro }].new(options)
      end

      self
    end

    def attribute(name, options = {})
      options[:from] = :"#{prefix}_#{name}" if prefix
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

      Mapper.new(header, model_class)
    end

  end

end
