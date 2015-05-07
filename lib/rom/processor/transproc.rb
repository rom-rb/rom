require 'transproc/all'

require 'rom/processor'

module ROM
  class Processor
    # Data mapping transformer builder using Transproc
    #
    # This builds a transproc function that is used to map a whole relation
    #
    # @see https://github.com/solnic/transproc too
    #
    # @private
    class Transproc < Processor
      include ::Transproc::Composer

      # @return [Header] header from a mapper
      #
      # @api private
      attr_reader :header

      # @return [Class] model class from a mapper
      #
      # @api private
      attr_reader :model

      # @return [Hash] header's attribute mapping
      #
      # @api private
      attr_reader :mapping

      # @return [Proc] row-processing proc
      #
      # @api private
      attr_reader :row_proc

      # Default no-op row_proc
      EMPTY_FN = -> tuple { tuple }.freeze

      # Build a transproc function from the header
      #
      # @param [ROM::Header] header
      #
      # @return [Transproc::Function]
      #
      # @api private
      def self.build(header)
        new(header).to_transproc
      end

      # @api private
      def initialize(header)
        @header = header
        @model = header.model
        @mapping = header.mapping
        initialize_row_proc
      end

      # Coerce mapper header to a transproc data mapping function
      #
      # @return [Transproc::Function]
      #
      # @api private
      def to_transproc
        compose(EMPTY_FN) do |ops|
          ops << header.combined.map { |attr| visit_combined(attr, true) }
          ops << header.groups.map { |attr| visit_group(attr, true) }
          ops << t(:map_array, row_proc) if row_proc
        end
      end

      private

      # Visit an attribute from the header
      #
      # This forwards to a specialized visitor based on the attribute type
      #
      # @param [Header::Attribute] attribute
      #
      # @api private
      def visit(attribute)
        type = attribute.class.name.split('::').last.downcase
        send("visit_#{type}", attribute)
      end

      # Visit plain attribute
      #
      # If it's a typed attribute a coercion transformation is added
      #
      # @param [Header::Attribute] attribute
      #
      # @api private
      def visit_attribute(attribute)
        if attribute.typed?
          t(:map_value, attribute.name, t(:"to_#{attribute.type}"))
        end
      end

      # Visit hash attribute
      #
      # @param [Header::Attribute::Hash] attribute
      #
      # @api private
      def visit_hash(attribute)
        with_row_proc(attribute) do |row_proc|
          t(:map_value, attribute.name, row_proc)
        end
      end

      # Visit array attribute
      #
      # @param [Header::Attribute::Array] attribute
      #
      # @api private
      def visit_array(attribute)
        with_row_proc(attribute) do |row_proc|
          t(:map_value, attribute.name, t(:map_array, row_proc))
        end
      end

      # Visit wrapped hash attribute
      #
      # :nest transformation is added to handle wrapping
      #
      # @param [Header::Attribute::Wrap] attribute
      #
      # @api private
      def visit_wrap(attribute)
        name = attribute.name
        keys = attribute.tuple_keys

        compose do |ops|
          ops << t(:nest, name, keys)
          ops << visit_hash(attribute)
        end
      end

      # Visit group hash attribute
      #
      # :group transformation is added to handle grouping during preprocessing.
      # Otherwise we simply use array visitor for the attribute.
      #
      # @param [Header::Attribute::Group] attribute
      # @param [Boolean] preprocess true if we are building a relation preprocessing
      #                             function that is applied to the whole relation
      #
      # @api private
      def visit_group(attribute, preprocess = false)
        if preprocess
          name = attribute.name
          header = attribute.header
          keys = attribute.tuple_keys

          other = header.groups

          compose do |ops|
            ops << t(:group, name, keys)

            ops << other.map { |attr|
              t(:map_array, t(:map_value, name, visit_group(attr, true)))
            }
          end
        else
          visit_array(attribute)
        end
      end

      # Visit combined attribute
      #
      # @api private
      def visit_combined(attribute, preprocess = false)
        if preprocess
          t(:combine, [
            [attribute.name, attribute.meta[:keys]]
          ])
        else
          with_row_proc(attribute) do |row_proc|
            t(:map_value, attribute.name, t(:map_array, row_proc))
          end
        end
      end

      # Build row_proc
      #
      # This transproc function is applied to each row in a dataset
      #
      # @api private
      def initialize_row_proc
        @row_proc = compose do |ops|
          ops << t(:rename_keys, mapping) if header.aliased?
          ops << header.map { |attr| visit(attr) }
          ops << t(-> tuple { model.new(tuple) }) if model
        end
      end

      # Yield row proc for a given attribute if any
      #
      # @param [Header::Attribute] attribute
      #
      # @api private
      def with_row_proc(attribute)
        row_proc = new(attribute.header).row_proc
        yield(row_proc) if row_proc
      end

      # Return a new instance of the processor
      #
      # @api private
      def new(*args)
        self.class.new(*args)
      end
    end
  end
end
