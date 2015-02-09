require 'rom/header'
require 'rom/mapper/model_dsl'

module ROM
  class Mapper
    # @api private
    class AttributeDSL
      include ModelDSL

      attr_reader :attributes, :options, :symbolize_keys, :prefix

      def initialize(attributes, options)
        @attributes = attributes
        @options = options
        @symbolize_keys = options[:symbolize_keys]
        @prefix = options[:prefix]
      end

      def attribute(name, options = EMPTY_HASH)
        with_attr_options(name, options) do |attr_options|
          add_attribute(name, attr_options)
        end
      end

      def exclude(*names)
        attributes.delete_if { |attr| names.include?(attr.first) }
      end

      def embedded(name, options, &block)
        with_attr_options(name) do |attr_options|
          dsl = new(options, &block)

          attr_options.update(options)

          add_attribute(
            name, { header: dsl.header, type: :array }.update(attr_options)
          )
        end
      end

      def wrap(*args, &block)
        with_name_or_options(*args) do |name, options|
          dsl(name, { type: :hash, wrap: true }.update(options), &block)
        end
      end

      def group(*args, &block)
        with_name_or_options(*args) do |name, options|
          dsl(name, { type: :array, group: true }.update(options), &block)
        end
      end

      def header
        Header.coerce(attributes, model)
      end

      private

      def with_attr_options(name, options = EMPTY_HASH)
        attr_options = options.dup

        attr_options[:from] ||= :"#{prefix}_#{name}" if prefix

        if symbolize_keys
          attr_options.update(from: attr_options.fetch(:from) { name }.to_s)
        end

        yield(attr_options)
      end

      def with_name_or_options(*args)
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
          attributes_from_block(name_or_attrs, options, &block)
        else
          attributes_from_hash(name_or_attrs, options)
        end
      end

      def attributes_from_block(name, options, &block)
        dsl = new(options, &block)
        header = dsl.header
        add_attribute(name, options.update(header: header))
        header.each { |attr| exclude(attr.key) }
      end

      def attributes_from_hash(hash, options)
        hash.each do |name, header|
          with_attr_options(name, options) do |attr_options|
            add_attribute(name, attr_options.update(header: header.zip))
            header.each { |attr| exclude(attr) }
          end
        end
      end

      def add_attribute(name, options)
        exclude(name, name.to_s)
        attributes << [name, options]
      end

      def new(options, &block)
        dsl = self.class.new([], @options.merge(options))
        dsl.instance_exec(&block)
        dsl
      end
    end
  end
end
