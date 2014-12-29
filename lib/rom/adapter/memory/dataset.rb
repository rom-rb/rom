module ROM
  class Adapter
    class Memory < Adapter
      class Dataset
        include Charlatan.new(:data)

        attr_reader :header

        def initialize(data, header)
          super
          @header = header
        end

        def to_ary
          data.dup
        end
        alias_method :to_a, :to_ary

        def each(&block)
          return to_enum unless block
          data.each(&block)
        end

        def join(*args)
          left, right = args.size > 1 ? args : [self, args.first]

          join_map = left.to_a.each_with_object({}) { |tuple, h|
            others = right.to_a.find_all { |t| (tuple.to_a & t.to_a).any? }
            (h[tuple] ||= []).concat(others)
          }

          tuples = left.map { |tuple|
            join_map[tuple].map { |other| tuple.merge(other) }
          }.flatten

          self.class.new(tuples, left.header + right.header)
        end

        def restrict(criteria = nil, &_block)
          if criteria
            find_all { |tuple| criteria.all? { |k, v| tuple[k] == v } }
          else
            find_all { |tuple| yield(tuple) }
          end
        end

        def project(*names)
          map { |tuple| tuple.reject { |key, _| names.include?(key) } }
        end

        def order(*names)
          sort_by { |tuple| tuple.values_at(*names) }
        end

        def insert(tuple)
          data << tuple
          self
        end

        def delete(tuple)
          data.delete(tuple)
          self
        end
      end
    end
  end
end
