require 'rom/adapter/data_proxy'

module ROM
  class Adapter
    class Memory < Adapter
      class Dataset
        include DataProxy

        # TODO: that's not all, we need to cherry-pick from:
        #       Array.public_instance_methods - Enumerable.public_instance_methods
        forward(
          Enumerable.public_instance_methods + [:map!, :map, :size, :flatten]
        )

        def join(*args)
          left, right = args.size > 1 ? args : [self, args.first]

          join_map = left.each_with_object({}) { |tuple, h|
            others = right.to_a.find_all { |t| (tuple.to_a & t.to_a).any? }
            (h[tuple] ||= []).concat(others)
          }

          tuples = left.map { |tuple|
            join_map[tuple].map { |other| tuple.merge(other) }
          }.flatten

          self.class.new(tuples, left.header + right.header)
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
end
