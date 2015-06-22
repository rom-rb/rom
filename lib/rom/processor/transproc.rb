require 'transproc/all'

require 'rom/processor'

require 'rom/processor/transproc/combine_processor'
require 'rom/processor/transproc/attributes_processor'
require 'rom/processor/transproc/rows_processor'

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

      # Default no-op row_proc
      EMPTY_FN = -> tuple { tuple }.freeze

      # Filter out empty tuples from an array
      FILTER_EMPTY = Transproc(
        -> arr { arr.reject { |row| row.values.all?(&:nil?) } }
      )

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
      end

      # Coerce mapper header to a transproc data mapping function
      #
      # @return [Transproc::Function]
      #
      # @api private
      def to_transproc
        compose(EMPTY_FN) do |ops|
          processors.each { |processor| ops << send(processor) }
        end
      end

      private

      def processors
        [:combine_processor, :header_preprocessor, :rows_processor, :header_postprocessor]
      end

      def combine_processor
        CombineProcessor.new(header.combined).to_transproc
      end

      def rows_processor
        RowsProcessor.new(header).to_transproc
      end

      def header_postprocessor
        AttributesProcessor.new(header.postprocessed).to_transproc
      end

      def header_preprocessor
        AttributesProcessor.new(header.preprocessed).to_transproc
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
