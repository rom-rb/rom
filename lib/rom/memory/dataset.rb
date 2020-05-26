# frozen_string_literal: true

require 'rom/array_dataset'

module ROM
  module Memory
    # In-memory dataset
    #
    # This class can be used as a base class for other adapters.
    #
    # @api public
    class Dataset
      include ArrayDataset

      # Join with other datasets
      #
      # @param [Array<Dataset>] args A list of dataset to join with
      #
      # @return [Dataset]
      #
      # @api public
      def join(*args)
        left, right = args.size > 1 ? args : [self, args.first]

        join_map = left.each_with_object({}) { |tuple, h|
          others = right.to_a.find_all { |t| (tuple.to_a & t.to_a).any? }
          (h[tuple] ||= []).concat(others)
        }

        tuples = left.flat_map { |tuple|
          join_map[tuple].map { |other| tuple.merge(other) }
        }

        self.class.new(tuples, **options)
      end

      # Restrict a dataset
      #
      # @param [Hash] criteria A hash with conditions
      #
      # @return [Dataset]
      #
      # @api public
      def restrict(criteria = nil)
        return find_all { |tuple| yield(tuple) } unless criteria

        find_all do |tuple|
          criteria.all? do |k, v|
            case v
            when Array then v.include?(tuple[k])
            when Regexp then tuple[k].match(v)
            else tuple[k].eql?(v)
            end
          end
        end
      end

      # Project a dataset
      #
      # @param [Array<Symbol>] names A list of attribute names
      #
      # @return [Dataset]
      #
      # @api public
      def project(*names)
        map { |tuple| tuple.select { |key| names.include?(key) } }
      end

      # Sort a dataset
      #
      # @param [Array<Symbol>] fields
      #   Names of fields to order tuples by
      #
      # @option [Boolean] :nils_first (false)
      #   Whether `nil` values should be placed before others
      #
      # @return [Dataset]
      #
      # @api public
      def order(*fields)
        nils_first = fields.pop[:nils_first] if fields.last.is_a?(Hash)

        sort do |a, b|
          fields # finds the first difference between selected fields of tuples
            .map { |n| __compare__ a[n], b[n], nils_first }
            .detect(-> { 0 }) { |r| r != 0 }
        end
      end

      # Insert tuple into a dataset
      #
      # @param [Hash] tuple A new tuple for insertion
      #
      # @api public
      #
      # @return [Dataset]
      def insert(tuple)
        data << tuple
        self
      end
      alias_method :<<, :insert

      # Delete tuples from a dataset
      #
      # @param [Hash] tuple A new tuple for deletion
      #
      # @return [Dataset]
      #
      # @api public
      def delete(tuple)
        data.delete(tuple)
        self
      end

      private

      # Compares two values, that are either comparable, or can be nils
      #
      # @api private
      def __compare__(a, b, nils_first)
        return a <=> b unless a.nil? ^ b.nil?

        nils_first ^ b.nil? ? -1 : 1
      end
    end
  end
end
