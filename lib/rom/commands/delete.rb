require 'rom/command'

module ROM
  module Commands
    # Delete command
    #
    # This command removes tuples from its target relation
    #
    # @abstract
    class Delete < Command
      restrictable true

      # @see AbstractCommand#call
      def call(*args)
        assert_tuple_count
        super
      end
    end
  end
end
