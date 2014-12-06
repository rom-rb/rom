module ROM
  module Commands

    # Common behavior for Create and Update commands
    #
    # TODO: find a better name for this module
    module WithOptions
      RESULTS = [:one, :many].freeze

      attr_reader :relation, :validator, :input, :result, :options

      # @api private
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

      # Call the command and return one or many tuples
      #
      # @api public
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
