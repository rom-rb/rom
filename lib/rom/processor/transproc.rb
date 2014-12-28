require 'transproc'
require 'transproc/coercions'
require 'transproc/hash'
require 'transproc/array'

require 'rom/processor'

module ROM
  class Processor
    class Transproc < Processor
      include ::Transproc::Composer

      attr_reader :header, :model, :mapping, :tuple_proc

      EMPTY_FN = -> tuple { tuple }.freeze

      def self.build(header)
        new(header).to_transproc
      end

      def initialize(header)
        @header = header
        @model = header.model
        @mapping = header.mapping
        initialize_tuple_proc
      end

      def to_transproc
        compose(EMPTY_FN) do |ops|
          ops << header.select(&:preprocess?).map { |attr| visit(attr, true) }
          ops << t(:map_array!, tuple_proc) if tuple_proc
        end
      end

      private

      def visit(attribute, preprocess = false)
        type = attribute.class.name.split('::').last.downcase
        send("visit_#{type}", attribute, preprocess)
      end

      def visit_attribute(attribute, preprocess = false)
        if attribute.typed?
          t(:map_key!, attribute.name, t(:"to_#{attribute.type}"))
        end
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
        name = attribute.name
        keys = attribute.header.tuple_keys

        compose do |ops|
          ops << t(:nest!, name, keys)
          ops << visit_hash(attribute)
        end
      end

      def visit_group(attribute, preprocess = false)
        if preprocess
          name = attribute.name
          header = attribute.header
          keys = header.tuple_keys
          other = header.select(&:preprocess?)

          compose do |ops|
            ops << t(:group, name, keys)

            ops << other.map { |attr|
              t(:map_array!, t(:map_key!, name, visit_group(attr, true)))
            }
          end
        else
          visit_array(attribute)
        end
      end

      def initialize_tuple_proc
        @tuple_proc = compose do |ops|
          ops << t(:map_hash!, mapping) if header.aliased?
          ops << header.map { |attr| visit(attr) }
          ops << t(-> tuple { model.new(tuple) }) if model
        end
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
