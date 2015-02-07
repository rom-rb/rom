require 'rom/command'

module ROM
  module Commands
    # Delete command
    #
    # This command removes tuples from its target relation
    #
    # @abstract
    class Delete < Command
      attr_reader :target

      # @api private
      def initialize(relation, options = {})
        super
        @target = options[:target] || relation
      end

      # @see AbstractCommand#call
      def call(*args)
        assert_tuple_count
        super
      end
    end
  end
end
