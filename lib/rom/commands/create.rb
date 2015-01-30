require 'rom/command'

module ROM
  module Commands
    # Create command
    #
    # This command inserts a new tuple into a relation
    #
    # @abstract
    class Create < Command
      # Execute the command
      #
      # @abstract
      #
      # @return [Array] an array with inserted tuples
      #
      # @api private
      def execute(*)
        raise(
          NotImplementedError,
          "#{self.class}##{__method__} must be implemented"
        )
      end
    end
  end
end
