require 'rom/support/array_dataset'

module ROM
  module Memory
    class Dataset
      include ArrayDataset

      def join(*args)
        left, right = args.size > 1 ? args : [self, args.first]

        join_map = left.each_with_object({}) { |tuple, h|
          others = right.to_a.find_all { |t| (tuple.to_a & t.to_a).any? }
          (h[tuple] ||= []).concat(others)
        }

        tuples = left.flat_map { |tuple|
          join_map[tuple].map { |other| tuple.merge(other) }
        }

        self.class.new(tuples, row_proc)
      end

      def restrict(criteria = nil)
        if criteria
          find_all { |tuple| criteria.all? { |k, v| tuple[k].eql?(v) } }
        else
          find_all { |tuple| yield(tuple) }
        end
      end

      def project(*names)
        map { |tuple| tuple.reject { |key| !names.include?(key) } }
      end

      def order(*names)
        sort_by { |tuple| tuple.values_at(*names) }
      end

      def insert(tuple)
        data << tuple
        self
      end
      alias_method :<<, :insert

      def delete(tuple)
        data.delete(tuple)
        self
      end
    end
  end
end
