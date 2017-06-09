module ROM
  class Relation
    # Extensions for relation classes which provide access to commands
    #
    # @api private
    module Commands
      # @api public
      def command(type, mapper: nil, use: EMPTY_ARRAY, **opts)
        command = commands[type, adapter, to_ast, use, opts]

        if mapper
          command >> mappers[mapper]
        elsif mappers.any? && !command.is_a?(CommandProxy)
          mappers.reduce(command) { |a, (_, e)| a >> e }
        elsif auto_struct?
          command >> self.mapper
        else
          command
        end
      end
    end
  end
end
