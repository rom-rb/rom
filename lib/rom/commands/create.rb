require 'rom/commands/with_options'

module ROM
  module Commands
    # Create command
    #
    # This command inserts a new tuple into a relation
    #
    # @abstract
    class Create < AbstractCommand
      include WithOptions

      # Execute the command
      #
      # @abstract
      #
      # @return [Array] an array with inserted tuples
      #
      # @api private
      def execute(_tuple)
        raise(
          NotImplementedError,
          "#{self.class}##{__method__} must be implemented"
        )
      end
    end
  end
end
