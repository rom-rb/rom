require 'rom/initializer'

module ROM
  class Changeset
    class Associated
      extend Initializer

      param :left
      param :right

      # @!attribute [r] association
      #   @return [Symbol] Association identifier from relation schema
      option :association, reader: true

      # Commit changeset's composite command
      #
      # @return [Array<Hash>, Hash]
      #
      # @api public
      def commit
        command.call
      end

      # Create a composed command
      #
      # This works *only* with parent => child(ren) changeset hierarchy
      #
      # @return [ROM::Command::Composite]
      #
      # @api public
      def command
        case right
        when Changeset, Associated
          left.command >> right.command.with_association(association)
        else
          left.create_command.with_association(association).curry(left, right)
        end
      end

      # @api private
      def relation
        left.relation
      end
    end
  end
end
