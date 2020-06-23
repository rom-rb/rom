# frozen_string_literal: true

require "rom/lint/linter"

module ROM
  module Lint
    # Ensures that a [ROM::EnumerableDataset] extension correctly yields
    # arrays and tuples
    #
    # @api public
    class EnumerableDataset < ROM::Lint::Linter
      # The linted subject
      #
      # @api public
      attr_reader :dataset

      # The expected data
      #
      # @api public
      attr_reader :data

      # Create a linter for EnumerableDataset
      #
      # @param [EnumerableDataset] dataset the linted subject
      # @param [Object] data the expected data
      #
      # @api public
      def initialize(dataset, data)
        @dataset = dataset
        @data = data
      end

      # Lint: Ensure that +dataset+ yield tuples via +each+
      #
      # @api public
      def lint_each
        result = []
        dataset.each do |tuple|
          result << tuple
        end
        return if result == data

        complain "#{dataset.class}#each must yield tuples"
      end

      # Lint: Ensure that +dataset+'s array equals to expected +data+
      #
      # @api public
      def lint_to_a
        return if dataset.to_a == data

        complain "#{dataset.class}#to_a must cast dataset to an array"
      end
    end
  end
end
