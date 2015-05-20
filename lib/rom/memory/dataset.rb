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
      # @api public
      def project(*names)
        map { |tuple| tuple.reject { |key| !names.include?(key) } }
      end

      # Sort a dataset
      #
      # @api public
      def order(*names)
        sort_by { |tuple| tuple.values_at(*names) }
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
