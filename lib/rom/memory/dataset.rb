require 'rom/support/array_dataset'

module ROM
  module Memory
    # In-memory dataset
    #
    # @api public
    class Dataset
      include ArrayDataset

      # Join two datasets
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

        self.class.new(tuples, options)
      end

      # Restrict a dataset
      #
      # @api public
      def restrict(criteria = nil)
        if criteria
          find_all { |tuple| criteria.all? { |k, v| tuple[k].eql?(v) } }
        else
          find_all { |tuple| yield(tuple) }
        end
      end

      # Project a dataset
      #
      # @api public
      def project(*names)
        map { |tuple| tuple.reject { |key| !names.include?(key) } }
      end

      # Sort a dataset
      #
      # @param [Array<Symbol>] names
      #   Names of fields to order tuples by
      #
      # @option [Boolean] :nils_first (false)
      #   Whether nil values should be placed before other ones
      #
      # @api public
      def order(*names, nils_first: false)
        place   = nils_first ? -1 : 1
        compare = ->(a, b) {
          return  place if a.nil?
          return -place if b.nil?
          a <=> b
        }

        sort do |a, b|
          names.map { |n| compare.call a[n], b[n] }.detect { |r| r != 0 } || 0
        end
      end

      # Insert tuple into a dataset
      #
      # @api public
      def insert(tuple)
        data << tuple
        self
      end
      alias_method :<<, :insert

      # Delete tuples from a dataset
      #
      # @api public
      def delete(tuple)
        data.delete(tuple)
        self
      end
    end
  end
end
