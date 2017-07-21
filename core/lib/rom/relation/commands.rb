module ROM
  class Relation
    # Extensions for relation classes which provide access to commands
    #
    # @api private
    module Commands
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
