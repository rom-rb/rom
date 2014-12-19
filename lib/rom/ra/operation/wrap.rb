module ROM
  module RA
    class Operation
      class Wrap
        # FIXME: only reading from a relation should be allowed here so this is
        #       obviously too much
        include Charlatan.new(:relation)

        include Enumerable

        attr_reader :options, :header

        def initialize(relation, options)
          super
          @options = options
          @header = relation.header + options.keys - attribute_names
        end

        def each(&block)
          return to_enum unless block

          results = relation.each_with_object([]) do |tuple, wrapped|
            result = tuple.reject { |k,_| attribute_names.include?(k) }
            result[key] = tuple.reject { |k,_| !attribute_names.include?(k) }

            wrapped << result
          end

          results.each(&block)
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
