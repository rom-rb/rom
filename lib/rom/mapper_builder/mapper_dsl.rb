require 'rom/mapper_builder/model_dsl'

module ROM
  class MapperBuilder
    # @api private
    class MapperDSL
      include ModelDSL

      attr_reader :attributes, :options, :symbolize_keys, :prefix

      def initialize(options = {})
        @attributes = []
        @options = options
        @symbolize_keys = options.fetch(:symbolize_keys) { false }
        @prefix = options.fetch(:prefix) { false }
        super
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
            { header: dsl.header, type: :array }.update(attr_options)
          ]
        end
      end

      def wrap(*args, &block)
        with_name_and_options(*args) do |name, options|
          dsl(name, { type: :hash, wrap: true }.update(options), &block)
        end
      end

      def group(*args, &block)
        with_name_and_options(*args) do |name, options|
          dsl(name, { type: :array, group: true }.update(options), &block)
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

      def with_name_and_options(*args)
        name, options =
          if args.size > 1
            args
          else
            [args.first, {}]
          end

        yield(name, options)
      end

      def dsl(name_or_attrs, options, &block)
        if block
          name = name_or_attrs

          dsl_options = @options.dup
          dsl_options.update(prefix: options.fetch(:prefix) { prefix })

          dsl = self.class.new(dsl_options)
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
