module ROM
  module Commands
    class Graph
      class InputEvaluator
        include Dry::Equalizer(:tuple_path, :excluded_keys)

        attr_reader :tuple_path

        attr_reader :excluded_keys

        attr_reader :exclude_proc

        def self.build(tuple_path, nodes)
          new(tuple_path, extract_excluded_keys(nodes))
        end

        def self.extract_excluded_keys(nodes)
          return unless nodes

          nodes
            .map { |item| item.is_a?(Array) && item.size > 1 ? item.first : item }
            .compact
            .map { |item| item.is_a?(Hash) ? item.keys.first : item }
            .reject { |item| item.is_a?(Array) }
        end

        def self.exclude_proc(excluded_keys)
          -> input { input.reject { |k, _| excluded_keys.include?(k) } }
        end

        def initialize(tuple_path, excluded_keys)
          @tuple_path = tuple_path
          @excluded_keys = excluded_keys
          @exclude_proc = self.class.exclude_proc(excluded_keys)
        end

        def call(*args)
          input, index = args

          value =
            begin
              if index
                tuple_path[0..tuple_path.size-2]
                  .reduce(input) { |a, e| a.fetch(e) }
                  .at(index)[tuple_path.last]
              else
                tuple_path.reduce(input) { |a, e| a.fetch(e) }
              end
            rescue KeyError => e
              raise KeyMissing, e.message
            end

          if excluded_keys
            value.is_a?(Array) ? value.map(&exclude_proc) : exclude_proc[value]
          else
            value
          end
        end
      end
    end
  end
end
