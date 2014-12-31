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

      # Create a new delete command scoped to specific relation and execute it
      #
      # @api private
      def new(*args, &block)
        new_options = options.merge(target: relation.public_send(*args, &block))
        command = self.class.new(relation, new_options)
        command.call
      end
    end
  end
end
