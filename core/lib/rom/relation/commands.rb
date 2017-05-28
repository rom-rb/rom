module ROM
  class Relation
    # Extensions for relation classes which provide access to commands
    #
    # @api private
    module Commands
      # @api public
      def command(type, mapper: nil, use: EMPTY_ARRAY, **opts)
        command = command_compiler[type, adapter, to_ast, use, opts]

        if mapper
          command >> mappers[mapper]
        elsif auto_struct?
          command >> self.mapper
        else
          command
        end
      end
    end
  end
end
