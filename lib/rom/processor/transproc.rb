module ROM
  module Processor
    class Transproc
      attr_reader :header, :model, :mapping, :tuple_proc

      def self.build(header)
        new(header).to_transproc
      end

      def initialize(header)
        @header = header
        @model = header.model
        @mapping = header.values.reject(&:preprocess?).map(&:mapping).reduce(:merge)
        initialize_tuple_proc
      end

      def to_transproc
        ops = []
        ops += header.select(&:preprocess?).map { |attr| visit(attr, true) }
        ops << t(:map_array!, tuple_proc) if tuple_proc

        ops.reduce(:+) || t(-> tuple { tuple })
      end

      private

      def visit(attribute, preprocess = false)
        type = attribute.class.name.split('::').last.downcase
        send("visit_#{type}", attribute, preprocess)
      end

      def visit_attribute(attribute, preprocess = false)
        # noop
      end

      def visit_hash(attribute, preprocess = false)
        with_tuple_proc(attribute) do |tuple_proc|
          t(:map_key!, attribute.name, tuple_proc)
        end
      end

      def visit_array(attribute, preprocess = false)
        with_tuple_proc(attribute) do |tuple_proc|
          t(:map_key!, attribute.name, t(:map_array!, tuple_proc))
        end
      end

      def visit_wrap(attribute, preprocess = false)
        ops = []

        name = attribute.name
        keys = attribute.header.tuple_keys

        ops << t(:fold, name, keys)
        ops << visit_hash(attribute)

        ops.compact.reduce(:+)
      end

      def visit_group(attribute, preprocess = false)
        if preprocess
          name = attribute.name
          header = attribute.header
          keys = header.tuple_keys
          other = header.select(&:preprocess?)

          ops = []
          ops << t(:group, name, keys)

          ops += other.map { |attr|
            t(:map_array!, t(:map_key!, name, visit_group(attr, true)))
          }

          ops.compact.reduce(:+)
        else
          visit_array(attribute)
        end
      end

      def initialize_tuple_proc
        ops = []
        ops << t(:map_hash!, mapping) if header.aliased?
        ops += header.map { |attr| visit(attr) }.compact
        ops << t(-> tuple { model.new(tuple) }) if model

        @tuple_proc = ops.reduce(:+)
      end

      def with_tuple_proc(attribute)
        tuple_proc = new(attribute.header).tuple_proc
        yield(tuple_proc) if tuple_proc
      end

      def t(*args)
        Transproc(*args)
      end

      def new(*args)
        self.class.new(*args)
      end

    end
  end
end
