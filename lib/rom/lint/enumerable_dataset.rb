require 'rom/lint/linter'

module ROM
  module Lint
    # Ensures that a [ROM::EnumerableDataset] extension correctly yields
    # arrays and tuples
    #
    # @public
    class EnumerableDataset < ROM::Lint::Linter
      attr_reader :dataset, :data

      def initialize(dataset, data)
        @dataset = dataset
        @data = data
      end

      def lint_each
        result = []
        dataset.each { |tuple| result << tuple }
        return if result == data

        complain "#{dataset.class}#each must yield tuples"
      end

      def lint_to_a
        return if dataset.to_a == data

        complain "#{dataset.class}#to_a must cast dataset to an array"
      end
    end
  end
end
