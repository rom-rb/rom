require 'transproc/all'

require 'rom/processor'

require 'rom/processor/transproc/combine_processor'
require 'rom/processor/transproc/attributes_processor'
require 'rom/processor/transproc/rows_processor'
require 'rom/processor/transproc/preprocessor'
require 'rom/processor/transproc/postprocessor'

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
          processors.each { |processor| ops << processor.new(@header).to_transproc }
        end
      end

      private

      # List of processors
      #
      # @api private
      def processors
        [CombineProcessor, Preprocessor, RowsProcessor, Postprocessor]
      end
    end
  end
end
