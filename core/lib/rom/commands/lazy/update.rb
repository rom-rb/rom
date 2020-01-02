# frozen_string_literal: true

module ROM
  module Commands
    class Lazy
      # Lazy command wrapper for update commands
      #
      # @api public
      class Update < Lazy
        # Execute a lazy update command
        #
        # @see Commands::Update#call
        #
        # @return [Hash, Array<Hash>]
        #
        # @api public
        def call(*args)
          first = args.first
          last = args.last
          size = args.size

          if size > 1 && last.is_a?(Array)
            last.map.with_index do |parent, index|
              children = evaluator.call(first, index)

              children.map do |child|
                command_proc[command, parent, child].call(child, parent)
              end
            end.reduce(:concat)
          else
            input = evaluator.call(first)

            if input.is_a?(Array)
              input.map.with_index do |item, index|
                command_proc[command, last, item].call(item, *args[1..size - 1])
              end
            else
              command_proc[command, *(size > 1 ? [last, input] : [input])]
                .call(input, *args[1..size - 1])
            end
          end
        end
      end
    end
  end
end
