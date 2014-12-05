module ROM
  module Commands

    module WithOptions
      RESULTS = [:one, :many].freeze

      attr_reader :relation, :validator, :input, :result, :options

      def initialize(relation, options)
        @relation = relation
        @options = options

        @validator = options.fetch(:validator)
        @input = options.fetch(:input)
        @result = options[:result] || :many

        if !RESULTS.include?(result)
          raise ArgumentError, "create command result #{@result.inspect} is not one of #{RESULTS.inspect}"
        end
      end

      def call(params)
        tuples = execute(params)

        if result == :one
          tuples.first
        else
          tuples
        end
      end

    end

  end
end
