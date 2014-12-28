require 'rom/model_builder'

module ROM
  # @api private
  class MapperBuilder
    class AttributeDSL
      attr_reader :attributes, :model_class, :model_builder

      def initialize
        @attributes = []
      end

      def attribute(name, options = {})
        attributes << [name, options]
      end

      def header
        Header.coerce(attributes, model)
      end

      def embedded(name, options = {}, &block)
        dsl = self.class.new
        dsl.instance_exec(&block)

        attributes << [
          name,
          { header: dsl.header, type: Array }.merge(options)
        ]
      end

      def wrap(options, &block)
        dsl(options, type: Hash, wrap: true, &block)
      end

      def group(options, &block)
        dsl(options, type: Array, group: true, &block)
      end

      def model(options = nil)
        if options.is_a?(Class)
          @model_class = options
        elsif options
          type = options.fetch(:type) { :poro }
          @model_builder = ModelBuilder[type].new(options)
        end

        if options
          self
        else
          model_class || (model_builder && model_builder.call(attributes.map(&:first)))
        end
      end

      private

      def dsl(args, options, &block)
        if block
          name = args

          dsl = AttributeDSL.new
          dsl.instance_exec(&block)
          attributes << [name, options.update(header: dsl.header)]
        else
          args.each do |name, header|
            attributes << [name, options.update(header: header.zip)]
          end
        end
      end
    end

    attr_reader :name, :root, :prefix,
      :model_builder, :model_class, :attributes

    def initialize(name, root, options = {})
      @name = name
      @root = root
      @prefix = options[:prefix]

      @attributes =
        if options[:inherit_header]
          root.header.map { |attr| [prefix ? :"#{prefix}_#{attr}" : attr] }
        else
          []
        end
    end

    def model(options)
      if options.is_a?(Class)
        @model_class = options
      else
        type = options.fetch(:type) { :poro }
        @model_builder = ModelBuilder[type].new(options)
      end

      self
    end

    def attribute(name, options = {})
      add_attribute(name, options) do
        options[:from] = :"#{prefix}_#{name}" if prefix
        attributes << [name, options]
      end
    end

    def exclude(name)
      attributes.delete([name])
    end

    def embedded(name, options = {}, &block)
      add_attribute(name, options) do
        dsl = AttributeDSL.new
        dsl.instance_exec(&block)

        attributes << [
          name,
          { header: dsl.header, type: Array }.merge(options)
        ]
      end
    end

    def group(*args, &block)
      dsl = AttributeDSL.new
      dsl.group(*args, &block)
      attributes.concat(dsl.attributes)
    end

    def wrap(*args, &block)
      dsl = AttributeDSL.new
      dsl.wrap(*args, &block)
      attributes.concat(dsl.attributes)
    end

    def call
      if model_builder
        @model_class = model_builder.call(attributes.map(&:first))
      end

      header = Header.coerce(attributes, model_class)

      Mapper.build(header, :transproc)
    end

    private

    def add_attribute(name, options = {})
      exclude(name)
      exclude(options[:from])
      yield
    end
  end
end
