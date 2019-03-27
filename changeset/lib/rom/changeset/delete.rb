# frozen_string_literal: true

module ROM
  class Changeset
    # Changeset specialization for delete commands
    #
    # Delete changesets will execute delete command for its relation, which
    # means proper restricted relations should be used with this changeset.
    #
    # @api public
    class Delete < Changeset
      command_type :delete
    end
  end
end
