require 'rom/command'

module ROM
  module Commands
    # Update command
    #
    # This command updates all tuples in its relation with new attributes
    #
    # @abstract
    class Update < Command
      restrictable true

      # @see AbstractCommand#call
      def call(*args)
        assert_tuple_count
        super
      end
    end
  end
end
