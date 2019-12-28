# frozen_string_literal: true

require 'dry/transformer/all'

require 'rom/processor'
require 'rom/processor/composer'

module ROM
  class Processor
    # Data mapping transformer builder using dry-transformer
    #
    # This builds a transformer object that is used to map a whole relation
    #
    # @see https://github.com/dry-rb/dry-transformer
    #
    # @private
    class Transformer < Processor
      include Composer

      module Functions
        extend Dry::Transformer::Registry

        import Dry::Transformer::Coercions
        import Dry::Transformer::ArrayTransformations
        import Dry::Transformer::HashTransformations
        import Dry::Transformer::ClassTransformations
        import Dry::Transformer::ProcTransformations

        INVALID_INJECT_UNION_VALUE = "%s attribute: block is required for :from with union value.".freeze

        def self.identity(tuple)
          tuple
        end

        def self.get(arr, idx)
          arr[idx]
        end

        def self.filter_empty(arr)
          arr.reject { |row| row.values.all?(&:nil?) }
        end

        def self.inject_union_value(tuple, name, keys, coercer)
          raise ROM::MapperMisconfiguredError, INVALID_INJECT_UNION_VALUE % [name] if !coercer

          values = tuple.values_at(*keys)
          result = coercer.call(*values)

          tuple.merge(name => result)
        end
      end

      # @return [Mapper] mapper that this processor belongs to
      #
      # @api private
      attr_reader :mapper

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

      # Build a transformer object from the header
      #
      # @param [ROM::Header] header
      #
      # @return [Dry::Transformer::Pipe]
      #
      # @api private
      def self.build(mapper, header)
        new(mapper, header).call
      end

      # @api private
      def initialize(mapper, header)
        @mapper = mapper
        @header = header
        @model = header.model
        @mapping = header.mapping
        initialize_row_proc
      end

      # Coerce mapper header to a transformer object
      #
      # @return [Dry::Transformer::Pipe]
      #
      # @api private
      def call
        compose(t(:identity)) do |ops|
          combined = header.combined
          ops << t(:combine, combined.map(&method(:combined_args))) if combined.any?
          ops << header.preprocessed.map { |attr| visit(attr, true) }
          ops << t(:map_array, row_proc) if row_proc
          ops << header.postprocessed.map { |attr| visit(attr, true) }
        end
      end

      private

      # Visit an attribute from the header
      #
      # This forwards to a specialized visitor based on the attribute type
      #
      # @param [Header::Attribute] attribute
      # @param [Array] args Allows to send `preprocess: true`
      #
      # @api private
      def visit(attribute, *args)
        type = attribute.class.name.split('::').last.downcase
        send("visit_#{type}", attribute, *args)
      end

      # Visit plain attribute
      #
      # It will call block transformation if it's used
      #
      # If it's a typed attribute a coercion transformation is added
      #
      # @param [Header::Attribute] attribute
      #
      # @api private
      def visit_attribute(attribute)
        coercer = attribute.meta[:coercer]
        if attribute.union?
          compose do |ops|
            ops << t(:inject_union_value, attribute.name, attribute.key, coercer)
            ops << t(:reject_keys, attribute.key) unless header.copy_keys
          end
        elsif coercer
          t(:map_value, attribute.name, t(:bind, mapper, coercer))
        elsif attribute.typed?
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

      # Visit combined attribute
      #
      # @api private
      def visit_combined(attribute)
        op = with_row_proc(attribute) do |row_proc|
          array_proc =
            if attribute.type == :hash
              t(:map_array, row_proc) >> t(:get, 0)
            else
              t(:map_array, row_proc)
            end

          t(:map_value, attribute.name, array_proc)
        end

        if op
          op
        elsif attribute.type == :hash
          t(:map_value, attribute.name, t(:get, 0))
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

      # Visit unwrap attribute
      #
      # :unwrap transformation is added to handle unwrapping
      #
      # @param [Header::Attributes::Unwrap] attribute
      #
      # @api private
      def visit_unwrap(attribute)
        name = attribute.name
        keys = attribute.pop_keys

        compose do |ops|
          ops << visit_hash(attribute)
          ops << t(:unwrap, name, keys)
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

          others = header.preprocessed

          compose do |ops|
            ops << t(:group, name, keys)
            ops << t(:map_array, t(:map_value, name, t(:filter_empty)))
            ops << others.map { |attr|
              t(:map_array, t(:map_value, name, visit(attr, true)))
            }
          end
        else
          visit_array(attribute)
        end
      end

      # Visit ungroup attribute
      #
      # :ungroup transforation is added to handle ungrouping during preprocessing.
      # Otherwise we simply use array visitor for the attribute.
      #
      # @param [Header::Attribute::Ungroup] attribute
      # @param [Boolean] preprocess true if we are building a relation preprocessing
      #                             function that is applied to the whole relation
      #
      # @api private
      def visit_ungroup(attribute, preprocess = false)
        if preprocess
          name = attribute.name
          header = attribute.header
          keys = attribute.pop_keys

          others = header.postprocessed

          compose do |ops|
            ops << others.map { |attr|
              t(:map_array, t(:map_value, name, visit(attr, true)))
            }
            ops << t(:ungroup, name, keys)
          end
        else
          visit_array(attribute)
        end
      end

      # Visit fold hash attribute
      #
      # :fold transformation is added to handle folding during preprocessing.
      #
      # @param [Header::Attribute::Fold] attribute
      # @param [Boolean] preprocess true if we are building a relation preprocessing
      #                             function that is applied to the whole relation
      #
      # @api private
      def visit_fold(attribute, preprocess = false)
        if preprocess
          name = attribute.name
          keys = attribute.tuple_keys

          compose do |ops|
            ops << t(:group, name, keys)
            ops << t(:map_array, t(:map_value, name, t(:filter_empty)))
            ops << t(:map_array, t(:fold, name, keys.first))
          end
        end
      end

      # Visit unfold hash attribute
      #
      # :unfold transformation is added to handle unfolding during preprocessing.
      #
      # @param [Header::Attribute::Unfold] attribute
      # @param [Boolean] preprocess true if we are building a relation preprocessing
      #                             function that is applied to the whole relation
      #
      # @api private
      def visit_unfold(attribute, preprocess = false)
        if preprocess
          name = attribute.name
          header = attribute.header
          keys = attribute.pop_keys
          key = keys.first

          others = header.postprocessed

          compose do |ops|
            ops << others.map { |attr|
              t(:map_array, t(:map_value, name, visit(attr, true)))
            }
            ops << t(:map_array, t(:map_value, name, t(:insert_key, key)))
            ops << t(:map_array, t(:reject_keys, [key] - [name]))
            ops << t(:ungroup, name, [key])
          end
        end
      end

      # Visit excluded attribute
      #
      # @param [Header::Attribute::Exclude] attribute
      #
      # @api private
      def visit_exclude(attribute)
        t(:reject_keys, [attribute.name])
      end

      # @api private
      def combined_args(attribute)
        other = attribute.header.combined

        if other.any?
          children = other.map(&method(:combined_args))
          [attribute.name, attribute.meta[:keys], children]
        else
          [attribute.name, attribute.meta[:keys]]
        end
      end

      # Build row_proc
      #
      # This transproc function is applied to each row in a dataset
      #
      # @api private
      def initialize_row_proc
        @row_proc = compose { |ops|
          alias_handler = header.copy_keys ? :copy_keys : :rename_keys
          process_header_keys(ops)

          ops << t(alias_handler, mapping) if header.aliased?
          ops << header.map { |attr| visit(attr) }
          ops << t(:constructor_inject, model) if model
        }
      end

      # Process row_proc header keys
      #
      # @api private
      def process_header_keys(ops)
        if header.reject_keys
          all_keys = header.tuple_keys + header.non_primitives.map(&:key)
          ops << t(:accept_keys, all_keys)
        end
        ops
      end

      # Yield row proc for a given attribute if any
      #
      # @param [Header::Attribute] attribute
      #
      # @api private
      def with_row_proc(attribute)
        row_proc = row_proc_from(attribute)
        yield(row_proc) if row_proc
      end

      # Build a row_proc from a given attribute
      #
      # This is used by embedded attribute visitors
      #
      # @api private
      def row_proc_from(attribute)
        new(mapper, attribute.header).row_proc
      end

      # Return a new instance of the processor
      #
      # @api private
      def new(*args)
        self.class.new(*args)
      end

      # @api private
      def t(*args)
        Functions[*args]
      end
    end
  end
end
