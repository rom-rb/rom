module ROM
  class Changeset
    # Changeset specialization for create commands
    #
    # @see Changeset::Stateful
    #
    # @api public
    class Create < Stateful
      command_type :create
    end
  end
end
