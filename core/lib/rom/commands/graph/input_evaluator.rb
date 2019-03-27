# frozen_string_literal: true

module ROM
  module Commands
    class Graph
      # Evaluator for lazy commands which extracts values for commands from nested hashes
      #
      # @api private
      class InputEvaluator
        include Dry::Equalizer(:tuple_path, :excluded_keys)

        # @!attribute [r] tuple_path
        #   @return [Array<Symbol>] A list of keys pointing to a value inside a hash
        attr_reader :tuple_path

        # @!attribute [r] excluded_keys
        #   @return [Array<Symbol>] A list of keys that should be excluded
        attr_reader :excluded_keys

        # @!attribute [r] exclude_proc
        #   @return [Array<Symbol>] A function that should determine which keys should be excluded
        attr_reader :exclude_proc

        # Build an input evaluator
        #
        # @param [Array<Symbol>] tuple_path The tuple path
        # @param [Array] nodes
        #
        # @return [InputEvaluator]
        #
        # @api private
        def self.build(tuple_path, nodes)
          new(tuple_path, extract_excluded_keys(nodes))
        end

        # @api private
        def self.extract_excluded_keys(nodes)
          return unless nodes

          nodes
            .map { |item| item.is_a?(Array) && item.size > 1 ? item.first : item }
            .compact
            .map { |item| item.is_a?(Hash) ? item.keys.first : item }
            .reject { |item| item.is_a?(Array) }
        end

        # Return default exclude_proc
        #
        # @api private
        def self.exclude_proc(excluded_keys)
          -> input { input.reject { |k, _| excluded_keys.include?(k) } }
        end

        # Initialize a new input evaluator
        #
        # @return [InputEvaluator]
        #
        # @api private
        def initialize(tuple_path, excluded_keys)
          @tuple_path = tuple_path
          @excluded_keys = excluded_keys
          @exclude_proc = self.class.exclude_proc(excluded_keys)
        end

        # Evaluate input hash
        #
        # @param [Hash] input The input hash
        # @param [Integer] index Optional index
        #
        # @return [Hash]
        def call(input, index = nil)
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
