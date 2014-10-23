module ROM
  module RA
    class Operation

      class Group
        include Concord::Public.new(:relation, :options)
        include Enumerable

        def each(&block)
          return to_enum unless block

          tuples = relation.to_a

          result = tuples.each_with_object({}) do |tuple, grouped|
            left = tuple.reject { |k,_| attribute_names.include?(k) }
            right = tuple.reject { |k,_| !attribute_names.include?(k) }

            grouped[left] ||= {}
            grouped[left][key] ||= [] << right
          end

          result.map { |k,v| k.merge(v) }.each(&block)
        end

        def key
          options.keys.first
        end

        def attribute_names
          options.values.first
        end

      end

    end
  end
end
