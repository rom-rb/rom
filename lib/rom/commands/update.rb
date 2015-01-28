module ROM
  module Commands
    # Update command
    #
    # This command updates all tuples in its relation with new attributes
    #
    # @abstract
    module Update
      # @see AbstractCommand#call
      def call(*args)
        assert_tuple_count
        super
      end
      alias_method :set, :call

      # Execute the update command
      #
      # @return [Array] an array with updated tuples
      #
      # @abstract
      #
      # @api private
      def execute(_params)
        raise(
          NotImplementedError,
          "#{self.class}##{__method__} must be implemented"
        )
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
