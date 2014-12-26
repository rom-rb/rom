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
        tuple_proc = Transproc.new(attribute.header).tuple_proc
        t(:map_key!, attribute.name, tuple_proc) if tuple_proc
      end

      def visit_array(attribute, preprocess = false)
        tuple_proc = Transproc.new(attribute.header).tuple_proc
        t(:map_key!, attribute.name, t(:map_array!, tuple_proc)) if tuple_proc
      end

      def visit_wrap(attribute, preprocess = false)
        if preprocess
          t(:wrap, attribute.name, attribute.header.mapping.keys)
        else
          visit_hash(attribute)
        end
      end

      def visit_group(attribute, preprocess = false)
        if preprocess
          t(:group, attribute.name, attribute.header.mapping.keys)
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

      def t(*args)
        Transproc(*args)
      end

    end
  end
end
