module ROM
  class Adapter
    class Memory < Adapter

      class Dataset
        include Charlatan.new(:data)

        def to_ary
          data.dup
        end
        alias_method :to_a, :to_ary

        def each(&block)
          return to_enum unless block
          data.each(&block)
        end

        def restrict(criteria = nil, &block)
          if criteria
            find_all { |tuple| criteria.all? { |k, v| tuple[k] == v } }
          else
            find_all { |tuple| yield(tuple) }
          end
        end

        def project(*names)
          map { |tuple| tuple.reject { |key,_| names.include?(key) } }
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

        def header
          []
        end

      end

    end
  end
end
