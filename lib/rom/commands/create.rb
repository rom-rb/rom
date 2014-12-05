module ROM
  module Commands

    class Create
      include Concord.new(:relation, :options)

      attr_reader :validator, :input, :result

      RESULTS = [:one, :many].freeze

      def initialize(relation, options)
        super

        @validator = options.fetch(:validator)
        @input = options.fetch(:input)
        @result = options[:result] || :many

        if !RESULTS.include?(result)
          raise ArgumentError, "create command result #{@result.inspect} is not one of #{RESULTS.inspect}"
        end
      end

      def execute(tuple)
        raise NotImplementedError, "#{self.class}#execute must be implemented"
      end

    end

  end
end
