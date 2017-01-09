module ROM
  class Changeset
    # Changeset specialization for create commands
    #
    # @api public
    class Create < Changeset
      # @!attribute [r] association
      #   @return [Array] Associated changesets with its association name
      option :association, reader: true, optional: true

      # @api public
      def associate(other, assoc)
        with(association: [other, assoc])
      end

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

      # @api private
      def command
        if options[:association]
          other, assoc = options[:association]

          if other.is_a?(Changeset)
            create_command.curry(self) >> other.command.with_association(assoc)
          else
            create_command.with_association(assoc).curry(self, other)
          end
        else
          create_command.curry(self)
        end
      end

      # @api private
      def create_command
        command_compiler.(command_type, relation, mapper: false, result: result)
      end

      # @api private
      def default_command_type
        :create
      end
    end
  end
end
