module ROM
  class Relation
    # Extensions for relation classes which provide access to commands
    #
    # @api public
    module Commands
      # Return a command for the relation
      #
      # @example
      #   users.command(:create)
      #
      # @param type [Symbol] The command type (:create, :update or :delete)
      # @option :mapper [ROM::Mapper] An optional mapper applied to the command result
      # @option :use [Array<Symbol>] A list of command plugins
      # @option :result [:one, :many] Whether the command result has one or more rows.
      #                               :one is default
      #
      # @return [ROM::Command]
      #
      # @api public
      def command(type, mapper: nil, use: EMPTY_ARRAY, **opts)
        base_command = commands[type, adapter, to_ast, use, opts]

        command =
          if mapper
            base_command >> mappers[mapper]
          elsif mappers.any? && !base_command.is_a?(CommandProxy)
            mappers.reduce(base_command) { |a, (_, e)| a >> e }
          elsif auto_struct? || auto_map?
            base_command >> self.mapper
          else
            base_command
          end

        if command.restrictible?
          command.new(self)
        else
          command
        end
      end
    end
  end
end
