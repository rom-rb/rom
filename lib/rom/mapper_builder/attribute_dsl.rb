module ROM
  class MapperBuilder
    # @api private
    class AttributeDSL
      attr_reader :attributes, :model_class, :model_builder, :options,
        :symbolize_keys, :prefix

      def initialize(options = {})
        @attributes = []
        @options = options
        @symbolize_keys = options.fetch(:symbolize_keys) { false }
        @prefix = options.fetch(:prefix) { false }
      end

      def attribute(name, options = {})
        with_attr_options(name, options) do |attr_options|
          attributes << [name, attr_options]
        end
      end

      def embedded(name, options = {}, &block)
        with_attr_options(name, options) do |attr_options|
          dsl = self.class.new(@options)
          dsl.instance_exec(&block)

          attributes << [
            name,
            { header: dsl.header, type: Array }.merge(attr_options)
          ]
        end
      end

      def wrap(*args, &block)
        name, options =
          if args.size > 1
            args
          else
            [args.first, {}]
          end

        dsl(name, { type: Hash, wrap: true }.update(options), &block)
      end

      def group(*args, &block)
        name, options =
          if args.size > 1
            args
          else
            [args.first, {}]
          end

        dsl(name, { type: Array, group: true }.update(options), &block)
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
          model_class || (
            model_builder && model_builder.call(attributes.map(&:first))
          )
        end
      end

      def header
        Header.coerce(attributes, model)
      end

      private

      def with_attr_options(name, options)
        attr_options = options.dup

        attr_options[:from] ||= :"#{prefix}_#{name}" if prefix

        if symbolize_keys
          attr_options.update(from: attr_options.fetch(:from) { name }.to_s)
        end

        yield(attr_options)
      end

      def dsl(name_or_attrs, options, &block)
        if block
          name = name_or_attrs

          dsl_options = @options.dup
          dsl_options.update(prefix: options.fetch(:prefix) { prefix })

          dsl = AttributeDSL.new(dsl_options)
          dsl.instance_exec(&block)

          with_attr_options(name, options) do |attr_options|
            attributes << [name, attr_options.update(header: dsl.header)]
          end
        else
          attrs = name_or_attrs

          attrs.each do |root, header|
            with_attr_options(name, options) do |attr_options|
              attributes << [root, attr_options.update(header: header.zip)]
            end
          end
        end
      end
    end
  end
end
