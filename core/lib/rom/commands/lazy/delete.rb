# frozen_string_literal: true

module ROM
  module Commands
    class Lazy
      # Lazy command wrapper for delete commands
      #
      # @api public
      class Delete < Lazy
        # Execute a lazy delete command
        #
        # @see Commands::Delete#call
        #
        # @return [Hash, Array<Hash>]
        #
        # @api public
        def call(*args)
          first = args.first
          last = args.last
          size = args.size

          if size > 1 && last.is_a?(Array)
            raise NotImplementedError
          else
            input = evaluator.call(first)

            if input.is_a?(Array)
              input.map do |item|
                command_proc[command, *(size > 1 ? [last, item] : [input])].call
              end
            else
              command_proc[command, input].call
            end
          end
        end
      end
    end
  end
end
