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

      # Call the command
      #
      # @return [Array]
      #
      # @see Delete#execute
      # @api public
      def call
        execute
      end

      # Execute the command
      #
      # @abstract
      #
      # @return [Array] an array with removed tuples
      #
      # @api private
      def execute
        raise NotImplementedError, "#{self.class}##{__method__} must be implemented"
      end

      # Return new delete command with new target
      #
      # @api private
      def new(*args, &block)
        self.class.new(relation, options.merge(target: relation.public_send(*args, &block)))
      end

    end

  end
end
