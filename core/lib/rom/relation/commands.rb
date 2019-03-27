# frozen_string_literal: true

module ROM
  class Relation
    # Extensions for relation classes which provide access to commands
    #
    # @api public
    module Commands
      # Return a command for the relation
      #
      # This method can either return an existing custom command identified
      # by `type` param, or generate a command dynamically based on relation
      # AST.
      #
      # @example build a simple :create command
      #   users.command(:create)
      #
      # @example build a command which returns multiple results
      #   users.command(:create, result: many)
      #
      # @example build a command which uses a specific plugin
      #   users.command(:create, plugin: :timestamps)
      #
      # @example build a command which sends results through a custom mapper
      #   users.command(:create, mapper: :my_mapper_identifier)
      #
      # @example return an existing custom command
      #   users.command(:my_custom_command_identifier)
      #
      # @param type [Symbol] The command type (:create, :update or :delete)
      # @param opts [Hash] Additional options
      # @option opts [Symbol] :mapper (nil) An optional mapper applied to the command result
      # @option opts [Array<Symbol>] :use ([]) A list of command plugins
      # @option opts [Symbol] :result (:one) Set how many results the command should return.
      #                                       Can be `:one` or `:many`
      #
      # @return [ROM::Command]
      #
      # @api public
      def command(type, mapper: nil, use: EMPTY_ARRAY, plugins_options: EMPTY_HASH, **opts)
        base_command =
          if commands.key?(type)
            commands[type]
          else
            commands[type, adapter, to_ast, use, plugins_options, opts]
          end

        command =
          if mapper
            base_command >> mappers[mapper]
          elsif auto_map?
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
