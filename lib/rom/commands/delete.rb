module ROM
  module Commands
    # Delete command
    #
    # This command removes tuples from its target relation
    #
    # @abstract
    class Delete < AbstractCommand
      attr_reader :target

      def initialize(relation, options)
        super
        @target = options[:target] || relation
      end

      # @see AbstractCommand#call
      def call(*args)
        assert_tuple_count
        super
      end

      # Execute the command
      #
      # @abstract
      #
      # @return [Array] an array with removed tuples
      #
      # @api private
      def execute
        raise(
          NotImplementedError,
          "#{self.class}##{__method__} must be implemented"
        )
      end

      # Return new delete command with new target
      #
      # @api private
      def new(*args, &block)
        new_options = options.merge(target: relation.public_send(*args, &block))
        self.class.new(relation, new_options)
      end
    end
  end
end
