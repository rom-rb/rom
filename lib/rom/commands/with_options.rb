module ROM
  module Commands
    # Common behavior for Create and Update commands
    #
    # TODO: find a better name for this module
    module WithOptions
      attr_reader :validator, :input

      # @api private
      def initialize(relation, options)
        super

        @validator = options[:validator] || Proc.new {}
        @input = options[:input] || Hash
      end
    end
  end
end
