require 'rom/commands/with_options'

module ROM
  module Commands
    # Update command
    #
    # This command updates all tuples in its relation with new attributes
    #
    # @abstract
    class Update < AbstractCommand
      include WithOptions

      alias_method :set, :call

      # @see AbstractCommand#call
      def call(*args)
        assert_tuple_count
        super
      end

      # Execute the update command
      #
      # @return [Array] an array with updated tuples
      #
      # @abstract
      #
      # @api private
      def execute(_params)
        name = "#{self.class}##{__method__}"
        raise NotImplementedError, "#{name} must be implemented"
      end

      # Return new update command with new relation
      #
      # @api private
      def new(*args, &block)
        self.class.new(relation.public_send(*args, &block), options)
      end
    end
  end
end
