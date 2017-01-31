module ROM
  class Changeset
    module Restricted
      # Return a command restricted by the changeset's relation
      #
      # @see Changeset#command
      #
      # @api private
      def command
        super.new(relation)
      end
    end
  end
end
