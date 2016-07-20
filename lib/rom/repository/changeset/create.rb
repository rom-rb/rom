module ROM
  class Changeset
    # Changeset specialization for create commands
    #
    # @api public
    class Create < Changeset
      # Return false
      #
      # @return [FalseClass]
      #
      # @api public
      def update?
        false
      end

      # Return true
      #
      # @return [TrueClass]
      #
      # @api public
      def create?
        true
      end
    end
  end
end
