require 'rom/command'
require 'rom/support/deprecations'

module ROM
  module Commands
    # Update command
    #
    # This command updates all tuples in its relation with new attributes
    #
    # @abstract
    class Update < Command
      extend Deprecations

      # @see AbstractCommand#call
      def call(*args)
        assert_tuple_count
        super
      end
      deprecate :set, :call
    end
  end
end
