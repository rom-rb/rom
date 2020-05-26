# frozen_string_literal: true

module ROM
  module Commands
    class Lazy
      # Lazy command wrapper for create commands
      #
      # @api public
      class Create < Lazy
        # Execute a command
        #
        # @see Command::Create#call
        #
        # @return [Hash,Array<Hash>]
        #
        # @api public
        def call(*args)
          first = args.first
          last = args.last
          size = args.size

          if size > 1 && last.is_a?(Array)
            last.map.with_index do |parent, index|
              children = evaluator.call(first, index)
              command_proc[command, parent, children].call(children, parent)
            end.reduce(:concat)
          else
            input = evaluator.call(first)
            command.call(input, *args[1..size - 1])
          end
        end
      end
    end
  end
end
