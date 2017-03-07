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

      # Restrict changeset's relation by its PK
      #
      # @example
      #   repo.changeset(UpdateUser).by_pk(1).data(name: "Jane")
      #
      # @param [Object] pk
      #
      # @return [Changeset]
      #
      # @api public
      def by_pk(pk, data = EMPTY_HASH)
        new(relation.by_pk(pk), __data__: data)
      end
    end
  end
end
