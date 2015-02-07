require 'rom/command'

module ROM
  module Commands
    # Update command
    #
    # This command updates all tuples in its relation with new attributes
    #
    # @abstract
    class Update < Command
      # @see AbstractCommand#call
      def call(*args)
        assert_tuple_count
        super
      end
      alias_method :set, :call
    end
  end
end
