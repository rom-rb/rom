module ROM
  class Processor
    class Transproc < Processor
      class RowsProcessor
        include ::Transproc::Composer

        # @return [Proc] row-processing proc
        #
        # @api private
        # attr_reader :row_proc
        attr_reader :row_proc

        def initialize(header)
          @header = header
          initialize_row_proc
        end

        def to_transproc
          t(:map_array, @row_proc) if @row_proc
        end

        private

        # Build row_proc
        #
        # This transproc function is applied to each row in a dataset
        #
        # @api private
        def initialize_row_proc
          @row_proc = compose { |ops|
            process_header_keys(ops)

            ops << t(:rename_keys, @header.mapping) if @header.aliased?
            ops << @header.map { |attr| visit(attr) }
            ops << t(:constructor_inject, @header.model) if @header.model
          }
        end

        def visit(attr)
          ROM::Processor::Transproc::Attribute.new(attr).to_transproc
        end

        # Process row_proc header keys
        #
        # @api private
        def process_header_keys(ops)
          if @header.reject_keys
            all_keys = @header.tuple_keys + @header.non_primitives.map(&:key)
            ops << t(:accept_keys, all_keys)
          end
          ops
        end
      end
    end
  end
end